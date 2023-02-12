import Database
import Foundation
import WebKit

public protocol UsesContentFilterManager {
    var contentFilterManager: ContentFilterManager { get }
}

@MainActor
public class ContentFilterManager {
    enum ImportError: LocalizedError {
        case someError([String: Error])
    }

    let settings: Settings

    let contentRuleListStore: WKContentRuleListStore

    public init(
        settings: Settings,
        contentRuleListStore: WKContentRuleListStore
    ) {
        self.settings = settings
        self.contentRuleListStore = contentRuleListStore
    }

    public var filterSettings: List<ContentFilterSetting> {
        return settings.contentFilterSettings
    }

    /// Imports filters.
    ///
    /// - Parameter filters: Filters.
    /// - Returns: A dictionary of errors.
    ///     A key is filter ID.
    ///     A value is error.
    public func `import`(filters: [ContentFilter]) async throws -> [Result<Void, Error>] {
        var results = [Result<Void, Error>]()
        var succeededSettings = [ContentFilterSetting]()

        for filter in filters {
            do {
                try await contentRuleListStore.compileContentRuleList(forIdentifier: filter.id, encodedContentRuleList: filter.encodedContentRuleList)

                succeededSettings.append(filter.setting)

                results.append(.success(()))
            } catch {
                results.append(.failure(error))
            }
        }

        try settings.realm!.write {
            settings.contentFilterSettings.append(objectsIn: succeededSettings)
        }

        return results
    }

    public func reloadFilters(userContentController: WKUserContentController) async throws {
        userContentController.removeAllContentRuleLists()

        if settings.contentFilterSettings.isEmpty {
            return
        }

        try await withThrowingTaskGroup(of: Void.self) { @MainActor group in
            for filter in settings.contentFilterSettings {
                if !filter.isEnabled {
                    logger.debug("\(#function) - Skip \(filter.id) \(filter.name)")
                    continue
                }

                logger.debug("\(#function) - Enable \(filter.id) \(filter.name)")

                group.addTask { @MainActor in
                    do {
                        let ruleList = try await self.contentRuleListStore.contentRuleList(forIdentifier: filter.id)!

                        userContentController.add(ruleList)
                    } catch {
                        logger.error("\(#function) - failed to lookup rule list \(filter.id) \(filter.name) - \(error)")
                    }
                }
            }

            try await group.waitForAll()
        }
    }

    public func observeFilters(_ block: @escaping () -> Void) -> NotificationToken {
        return settings.contentFilterSettings.observe { change in
            switch change {
            case .update:
                block()

            default: ()
            }
        }
    }
}

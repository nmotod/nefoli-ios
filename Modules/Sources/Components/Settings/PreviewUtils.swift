import ContentBlocker
import Database
import Foundation
import RealmSwift

#if DEBUG

enum PreviewUtils {
    static let realm = try! Realm(configuration: .init(inMemoryIdentifier: UUID().uuidString))

    static let settings: Settings = {
        let rootState = RootState()
        let settings = Settings()
        rootState.settings = settings

        settings.contentFilterSettings.append(objectsIn: [
            .init(name: "Filter 01"),
            .init(name: "Filter 02"),
        ])

        try! realm.write {
            realm.add(rootState)
        }

        return settings
    }()

    @MainActor
    static let contentFilterManager = ContentFilterManager(settings: settings, contentRuleListStore: .default()!)
}

#endif

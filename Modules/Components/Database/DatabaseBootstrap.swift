import Foundation
import RealmSwift

public class DatabaseBootstrap {
    public typealias SeedLoader = () async throws -> RootState?

    public let seedLoader: SeedLoader

    public init(seedLoader: @escaping SeedLoader) {
        self.seedLoader = seedLoader
    }

    public var database: DatabaseContainer {
        get async throws { try await bootstrapTask.value }
    }

    private lazy var bootstrapTask = Task { @MainActor () throws -> DatabaseContainer in
        let realm = try Realm(configuration: makeConfiguration())

        let rootState: RootState
        let bookmarksFolder: BookmarkItem
        let favoritesFolder: BookmarkItem
        let settings: Settings

        if let aRootState = realm.objects(RootState.self).first {
            rootState = aRootState

        } else {
            rootState = try await seedLoader() ?? RootState()
        }

        if let aFolder = rootState.bookmarksFolder {
            bookmarksFolder = aFolder
        } else {
            bookmarksFolder = .init(id: .bookmarks)
        }

        if let aFolder = rootState.favoritesFolder {
            favoritesFolder = aFolder
        } else {
            favoritesFolder = .init(id: .favorites)
        }

        if let aSettings = rootState.settings {
            settings = aSettings
        } else {
            settings = .init()
        }

        if rootState.realm == nil
            || rootState.bookmarksFolder == nil
            || rootState.favoritesFolder == nil
            || rootState.settings == nil
            || rootState.groups.isEmpty
        {
            try realm.write {
                if rootState.realm == nil {
                    realm.add(rootState)
                }

                if rootState.bookmarksFolder == nil {
                    rootState.bookmarksFolder = bookmarksFolder
                }

                if rootState.favoritesFolder == nil {
                    rootState.favoritesFolder = favoritesFolder
                }

                if rootState.settings == nil {
                    rootState.settings = settings
                }

                if rootState.groups.isEmpty {
                    rootState.groups.append(TabGroup())
                }
            }
        }

        return DatabaseContainer(
            realm: realm,
            rootState: rootState,
            bookmarksFolder: bookmarksFolder,
            favoritesFolder: favoritesFolder,
            settings: settings
        )
    }
}

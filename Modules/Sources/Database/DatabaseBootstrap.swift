import Foundation
import RealmSwift

public class DatabaseBootstrap {
    public typealias SeedLoader = () async throws -> RootState?

    public let seedLoader: SeedLoader

    public init(seedLoader: @escaping SeedLoader) {
        self.seedLoader = seedLoader
    }

    public var database: Database {
        get async throws { try await bootstrapTask.value }
    }

    private lazy var bootstrapTask = Task { @MainActor () throws -> Database in
        let configuration = Realm.Configuration(
            schemaVersion: schemaVersion,
            migrationBlock: doMigrate(_:oldSchemaVersion:)
        )

        let realm = try Realm(configuration: configuration)

        let rootState: RootState
        let bookmarksFolder: BookmarkItem
        let favoritesFolder: BookmarkItem

        if let aRootState = realm.objects(RootState.self).first {
            rootState = aRootState

        } else {
            rootState = try await seedLoader() ?? RootState()
        }

        if let aFolder = rootState.bookmarksFolder {
            bookmarksFolder = aFolder
        } else {
            bookmarksFolder = .init()
        }

        if let aFolder = rootState.favoritesFolder {
            favoritesFolder = aFolder
        } else {
            favoritesFolder = .init()
        }

        if rootState.realm == nil
            || rootState.bookmarksFolder == nil
            || rootState.favoritesFolder == nil
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
            }
        }

        return Database(
            realm: realm,
            rootState: rootState,
            bookmarksFolder: bookmarksFolder,
            favoritesFolder: favoritesFolder
        )
    }
}

import Foundation
import os.log
import RealmSwift

let schemaVersion: UInt64 = 20

func doMigrate(_ migration: Migration, oldSchemaVersion: UInt64) {
    let log = Logger(category: "migration")

    log.info("doMigrate - \(oldSchemaVersion, privacy: .public) => \(schemaVersion, privacy: .public)")

    if oldSchemaVersion < 14 {
        migration.enumerateObjects(ofType: "RootState") { _, newObject in
            let favoritesFolder = newObject!["favoritesFolder"] as! MigrationObject
            favoritesFolder["id"] = BookmarkItemID.favorites.persistableValue

            let bookmarksFolder = newObject!["bookmarksFolder"] as! MigrationObject
            bookmarksFolder["id"] = BookmarkItemID.bookmarks.persistableValue
        }
    }

    if oldSchemaVersion < 15 {
        migration.enumerateObjects(ofType: "RootState") { _, newObject in
            let favoritesFolder = newObject!["favoritesFolder"] as! MigrationObject
            favoritesFolder["kind"] = BookmarkItem.Kind.folder.rawValue

            let bookmarksFolder = newObject!["bookmarksFolder"] as! MigrationObject
            bookmarksFolder["kind"] = BookmarkItem.Kind.folder.rawValue
        }
    }

    // fix special bookmark folders ID
    if oldSchemaVersion < 17 {
        migration.enumerateObjects(ofType: "RootState") { _, newObject in
            let favoritesFolder = newObject!["favoritesFolder"] as! MigrationObject
            favoritesFolder["id"] = BookmarkItemID.favorites.persistableValue
            favoritesFolder["kind"] = BookmarkItem.Kind.folder.rawValue

            let bookmarksFolder = newObject!["bookmarksFolder"] as! MigrationObject
            bookmarksFolder["id"] = BookmarkItemID.bookmarks.persistableValue
            bookmarksFolder["kind"] = BookmarkItem.Kind.folder.rawValue
        }
    }

    // v18 does not require manual migration

    // v19: add Tab.sessionState

    // v20:
    //   added:
    //     - Tab.lastURL
    //     - Tab.lastTitle
    //   deleted:
    //     - Tab.backList
    //     - Tab.forwardList
    //     - Tab.current
}

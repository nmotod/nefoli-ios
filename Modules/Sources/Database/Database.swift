import Foundation
import RealmSwift

public class Database {
    public let realm: Realm
    public let rootState: RootState
    public let bookmarksFolder: BookmarkItem
    public let favoritesFolder: BookmarkItem

    init(realm: Realm, rootState: RootState, bookmarksFolder: BookmarkItem, favoritesFolder: BookmarkItem) {
        assert(rootState.bookmarksFolder!.isSameObject(as: bookmarksFolder))
        assert(rootState.favoritesFolder!.isSameObject(as: favoritesFolder))

        self.realm = realm
        self.rootState = rootState
        self.bookmarksFolder = bookmarksFolder
        self.favoritesFolder = favoritesFolder
    }
}

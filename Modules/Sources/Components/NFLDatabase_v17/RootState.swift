import Foundation
import RealmSwift

public class RootState: Object {
    @Persisted public var groups: List<TabGroup>

    @Persisted public var closedTabs: List<Tab>

    @Persisted public var bookmarksFolder: BookmarkItem?

    @Persisted public var favoritesFolder: BookmarkItem?

    @Persisted public var settings: Settings?

    public convenience init(
        groups: [TabGroup],
        closedTabs: [Tab],
        bookmarksFolder: BookmarkItem,
        favoritesFolder: BookmarkItem,
        settings: Settings
    ) {
        self.init()

        self.groups.append(objectsIn: groups)
        self.closedTabs.append(objectsIn: closedTabs)
        self.bookmarksFolder = bookmarksFolder
        self.favoritesFolder = favoritesFolder
        self.settings = settings
    }
}

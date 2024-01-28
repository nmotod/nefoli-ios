#if DEBUG

import Foundation
import NFLDatabase
import RealmSwift

private func makeFolder(
    id: BookmarkItemID?,
    title: String,
    children: [BookmarkItem]
) -> BookmarkItem {
    let item = BookmarkItem(id: id)
    item.kind = .folder
    item.title = title
    item.children.append(objectsIn: children)
    return item
}

private func makeBookmark(
    id: String?,
    title: String,
    urlString: String
) -> BookmarkItem {
    let item = BookmarkItem()
    item.kind = .bookmark
    item.title = title
    item.url = URL(string: urlString)
    return item
}

enum PreviewUtils {
    static let realm = try! Realm(configuration: .init(inMemoryIdentifier: UUID().uuidString))

    @MainActor static var deepFavoritesFolder: BookmarkItem = {
        let folder = BookmarkItem()
        folder.kind = .folder
        folder.title = "Deep Favorites"
        folder.children.append(objectsIn: [
            makeBookmark(id: nil, title: "D 1", urlString: "https://example.com/d1"),
            makeBookmark(id: nil, title: "D 2", urlString: "https://example.com/d2"),
            makeBookmark(id: nil, title: "D 3", urlString: "https://example.com/d3"),
        ])
        return folder
    }()

    @MainActor static var deepFolder: BookmarkItem = {
        let folder = BookmarkItem()
        folder.kind = .folder
        folder.title = "Deep"
        folder.children.append(objectsIn: [
            makeBookmark(id: nil, title: "D 1", urlString: "https://example.com/d1"),
            makeBookmark(id: nil, title: "D 2", urlString: "https://example.com/d2"),
            makeBookmark(id: nil, title: "D 3", urlString: "https://example.com/d3"),
        ])
        return folder
    }()

    @MainActor static var bookmarkStore: BookmarkStore = {
        let rootState = RootState()
        let bookmarksFolder = makeFolder(id: .bookmarks, title: "", children: [
            makeBookmark(id: nil, title: "Bookmark 1", urlString: "https://example.com/1"),
            makeBookmark(id: nil, title: "Bookmark 2", urlString: "https://example.com/2"),
            makeBookmark(id: nil, title: "Bookmark 3", urlString: "https://example.com/3"),
            deepFolder,
        ])

        let favoritesFolder = makeFolder(id: .favorites, title: "", children: [
            makeBookmark(id: nil, title: "Favorite 1", urlString: "https://example.com/1"),
            makeBookmark(id: nil, title: "Favorite 2", urlString: "https://example.com/2"),
            makeBookmark(id: nil, title: "Favorite 3", urlString: "https://example.com/3"),
            deepFavoritesFolder,
        ])

        rootState.bookmarksFolder = bookmarksFolder
        rootState.favoritesFolder = favoritesFolder

        try! realm.write {
            realm.add(rootState)
        }

        return BookmarkStore(
            bookmarksFolder: bookmarksFolder,
            favoritesFolder: favoritesFolder
        )
    }()

    @MainActor static var emptyBookmarkStore: BookmarkStore = {
        let rootState = RootState()
        let bookmarksFolder = makeFolder(id: .bookmarks, title: "", children: [])

        let favoritesFolder = makeFolder(id: .favorites, title: "", children: [])

        rootState.bookmarksFolder = bookmarksFolder
        rootState.favoritesFolder = favoritesFolder

        try! realm.write {
            realm.add(rootState)
        }

        return BookmarkStore(
            bookmarksFolder: bookmarksFolder,
            favoritesFolder: favoritesFolder
        )
    }()
}

#endif

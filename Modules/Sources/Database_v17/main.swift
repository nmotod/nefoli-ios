import Foundation
import RealmSwift

let fileURL = URL(filePath: NSTemporaryDirectory()).appending(component: "v17.realm")

if FileManager.default.fileExists(atPath: fileURL.path) {
    try! FileManager.default.removeItem(at: fileURL)
}

let realm = try! Realm(configuration: .init(
    fileURL: fileURL,
    schemaVersion: schemaVersion
))

print(fileURL.path())

let root = RootState(value: [
    "groups": [
        [
            "id": "g1",
            "activeTabId": "t1-2",
            "children": [
                [
                    "id": "t1-1",
                    "initialURL": "https://example.com/t1-1",
                ],
                [
                    "id": "t1-2",
                    "initialURL": "https://example.com/t1-2",
                ],
            ],
        ],
        [
            "id": "g2",
            "activeTabId": "t2-2",
            "children": [
                [
                    "id": "t2-1",
                    "initialURL": "https://example.com/t2-1",
                ],
                [
                    "id": "t2-2",
                    "initialURL": "https://example.com/t2-2",
                ],
            ],
        ],
    ],
    "closedTabs": [],
    "bookmarksFolder": [
        "id": BookmarkItemID.bookmarks.persistableValue,
        "kind": BookmarkItem.Kind.folder.rawValue,
        "children": [],
    ],
    "favoritesFolder": [
        "id": BookmarkItemID.favorites.persistableValue,
        "kind": BookmarkItem.Kind.folder.rawValue,
        "children": [],
    ],
    "settings": [:],
])

try! realm.write {
    realm.add(root)
}

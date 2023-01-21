@testable import Bookmarks
import Database
import LinkPresentation
import RealmSwift
import XCTest

final class BookmarkIconManager_PathTests: XCTestCase {
    func testPath() throws {
        let item = BookmarkItem()
        item.url = URL(string: "https://example.com/")!

        let manager = BookmarkIconManager(
            maxSize: .zero,
            cachesDirectoryURL: URL(string: "file:///tmp/icons")!
        )

        let cacheURL = manager.cacheFileURL(for: item)

        XCTAssertEqual(
            // echo -n 'https://example.com/' | sha256sum
            "file:///tmp/icons/" + item.id,
            cacheURL.absoluteString,
            "file name is SHA256 lower-case hex string"
        )
    }
}

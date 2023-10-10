@testable import Bookmarks
import Database
import LinkPresentation
import RealmSwift
import UniformTypeIdentifiers
import XCTest

private func generateMockImage(size: CGSize) -> UIImage {
    UIGraphicsBeginImageContext(size)

    let c = UIGraphicsGetCurrentContext()!
    c.setFillColor(UIColor.red.cgColor)
    c.fill([CGRect(origin: .zero, size: size)])

    let image = UIGraphicsGetImageFromCurrentImageContext()!

    UIGraphicsEndImageContext()

    return image
}

final class BookmarkIconManager_ImageTests: XCTestCase {
    class MockMetadataProvider: LPMetadataProvider {
        var iconProvider: NSItemProvider?

        override func startFetchingMetadata(for url: URL, completionHandler: @escaping (LPLinkMetadata?, Error?) -> Void) {
            _ = url
            let metadata = LPLinkMetadata()
            metadata.title = "mock"
            metadata.url = url
            metadata.iconProvider = iconProvider

            completionHandler(metadata, nil)
        }
    }

    var metadataProvider = MockMetadataProvider()

    lazy var iconManager = BookmarkIconManager(
        maxSize: .init(width: 60, height: 60),
        cachesDirectoryURL: URL.temporaryDirectory.appending(component: UUID().uuidString),
        metadataProviderFactory: { [weak self] in
            return self!.metadataProvider
        }
    )

    let realm = try! Realm(configuration: .init(inMemoryIdentifier: UUID().uuidString))

    var item: BookmarkItem!

    override func setUpWithError() throws {
        try super.setUpWithError()

        item = BookmarkItem()
        item.url = URL(string: "https://example.com/")

        try realm.write {
            realm.add(item)
        }
    }

    func testKeepSize() async throws {
        // Don't resize
        metadataProvider.iconProvider = NSItemProvider(object: generateMockImage(size: .init(width: 33, height: 33)))

        guard let image = try await iconManager.getImage(for: item) else {
            XCTFail()
            return
        }

        XCTAssertEqual(CGSize(width: 33, height: 33), image.size)
    }

    func testResize() async throws {
        // Resize to 60x60
        metadataProvider.iconProvider = NSItemProvider(object: generateMockImage(size: .init(width: 100, height: 100)))

        guard let image = try await iconManager.getImage(for: item) else {
            XCTFail()
            return
        }

        XCTAssertEqual(CGSize(width: 60, height: 60), image.size)
    }

    func testBinary() async throws {
        let iconProvider = NSItemProvider()
        metadataProvider.iconProvider = iconProvider

        iconProvider.registerDataRepresentation(for: UTType(mimeType: "image/x-icon")!) { completionHandler in
            Task {
                let data = generateMockImage(size: .init(width: 11, height: 11)).pngData()
                completionHandler(data!, nil)
            }

            return Progress()
        }

        guard let image = try await iconManager.getImage(for: item) else {
            XCTFail()
            return
        }

        XCTAssertEqual(CGSize(width: 11, height: 11), image.size)
    }
}

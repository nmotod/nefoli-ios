import Foundation
@testable import Utils
import XCTest

class HatenaBookmarkURLGeneratorTests: XCTestCase {
    private let generator = HatenaBookmarkURLGenerator()

    func testHttp() {
        let entryURL = generator.entryURL(of: URL(string: "http://example.com/pa/th/%E3%81%82?q=foo%20oo#bar")!)

        XCTAssertEqual(entryURL!.absoluteString, "https://b.hatena.ne.jp/entry/example.com/pa/th/%E3%81%82?q=foo%20oo#bar")
    }

    func testHttps() {
        let entryURL = generator.entryURL(of: URL(string: "https://example.com/pa/th?q=foo#bar")!)

        XCTAssertEqual(entryURL!.absoluteString, "https://b.hatena.ne.jp/entry/s/example.com/pa/th?q=foo#bar")
    }
}

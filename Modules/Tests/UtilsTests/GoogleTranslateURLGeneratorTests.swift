@testable import Utils
import XCTest

final class GoogleTranslateURLGeneratorTests: XCTestCase {
    func testToJaWithQueryAndHash() throws {
        let generator = GoogleTranslateURLGenerator(translationLanguage: "ja")

        let trURL = generator.translationURL(from: URL(string: "https://sub.of.example.com/pa/th?q=uery#hash")!)

        XCTAssertEqual(trURL?.absoluteString, "https://sub-of-example-com.translate.goog/pa/th?q=uery&_x_tr_sl=auto&_x_tr_tl=ja&_x_tr_hl=auto&_x_tr_pto=wapp#hash")
    }

    func testToFr() throws {
        let generator = GoogleTranslateURLGenerator(translationLanguage: "fr")

        let trURL = generator.translationURL(from: URL(string: "https://sub.of.example.com/pa/th")!)

        XCTAssertEqual(trURL?.absoluteString, "https://sub-of-example-com.translate.goog/pa/th?_x_tr_sl=auto&_x_tr_tl=fr&_x_tr_hl=auto&_x_tr_pto=wapp")
    }
}

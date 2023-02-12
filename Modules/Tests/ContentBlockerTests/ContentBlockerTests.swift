@testable import ContentBlocker
import Database
import WebKit
import XCTest

enum DecodingError: Error {
    case jsonDecodeError(Error)
    case syntaxError
}

private func decodeOneBlockerFilters(data: Data) throws -> [ContentFilterSetting] {
    let root: Any

    do {
        root = try JSONSerialization.jsonObject(with: data)
    } catch {
        throw DecodingError.jsonDecodeError(error)
    }

    guard let array = root as? [Any] else {
        throw DecodingError.syntaxError
    }

    return try array.map { item in
        guard let dict = item as? [String: Any] else {
            throw DecodingError.syntaxError
        }

        guard dict["rules"] is [Any] else {
            throw DecodingError.syntaxError
        }

        return ContentFilterSetting(
            sourceID: dict["id"] as? String,
            name: dict["name"] as? String
        )
    }
}

final class ContentBlockerTests: XCTestCase {
    func test() throws {
        let data = """
        [
            {
                "id": "FC0E2234-C051-4B90-84E4-E520187DE22D",
                "name": "filter1",
                "rules": []
            },
            {
                "id": "38F103B7-68DE-4C35-B667-81445ED677E0",
                "name": "filter2",
                "rules": []
            }
        ]
        """.data(using: .utf8)!

        let filters = try decodeOneBlockerFilters(data: data)

        XCTAssertEqual(2, filters.count)

        XCTAssertFalse(filters[0].id.isEmpty)
        XCTAssertEqual("FC0E2234-C051-4B90-84E4-E520187DE22D", filters[0].sourceID)

        XCTAssertFalse(filters[1].id.isEmpty)
        XCTAssertEqual("38F103B7-68DE-4C35-B667-81445ED677E0", filters[1].sourceID)
    }

    func testJSONDecodeError() throws {
        let data = "[".data(using: .utf8)!

        XCTAssertThrowsError(try decodeOneBlockerFilters(data: data)) { error in
            guard case DecodingError.jsonDecodeError = error else {
                XCTFail("Expected .malformedJSON, but \(error)"); return
            }
        }
    }

    func testSyntaxError() throws {
        let data = """
        [
            {
                "//": "no 'rules'"
            }
        ]
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decodeOneBlockerFilters(data: data)) { error in
            guard case DecodingError.syntaxError = error else {
                XCTFail("Expected .syntaxError, but \(error)"); return
            }
        }
    }
}

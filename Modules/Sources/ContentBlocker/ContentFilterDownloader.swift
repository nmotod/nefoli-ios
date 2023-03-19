import Database
import Foundation

public class ContentFilterDownloader {
    public enum DecodeError: LocalizedError {
        case syntaxError
        case httpError(HTTPURLResponse)

        public var errorDescription: String? {
            switch self {
            case .syntaxError:
                return "syntax error"

            case let .httpError(response):
                return HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
            }
        }
    }

    public init() {}

    public func download(url: URL) async throws -> [ContentFilter] {
        let (data, response) = try await URLSession.shared.data(from: url)

        print(response)

        if let response = response as? HTTPURLResponse,
           (response.statusCode / 100) != 2
        {
            throw DecodeError.httpError(response)
        }

        return try decodeOneBockerPackage(data: data, sourceURL: url)
    }

    func decodeOneBockerPackage(data: Data, sourceURL: URL) throws -> [ContentFilter] {
        guard let root = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw DecodeError.syntaxError
        }

        return try root.map {
            guard let obRules = $0["rules"] as? [[String: Any]] else {
                throw DecodeError.syntaxError
            }

            let wkRules = obRules.map {
                $0["content"]
            }

            let setting = ContentFilterSetting(
                name: $0["name"] as? String ?? "",
                sourceURL: sourceURL,
                sourceID: $0["id"] as? String
            )

            let encoded = try String(data: JSONSerialization.data(withJSONObject: wkRules), encoding: .utf8)

            return ContentFilter(
                setting: setting,
                encodedContentRuleList: encoded!
            )
        }
    }
}

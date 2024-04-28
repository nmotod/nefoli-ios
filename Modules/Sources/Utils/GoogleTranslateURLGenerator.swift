import Foundation

public struct GoogleTranslateURLGenerator {
    public let sourceLanguage: String
    public let translationLanguage: String
    public let hostLanguage: String

    public init(
        sourceLanguage: String = "auto",
        translationLanguage: String,
        hostLanguage: String = "auto"
    ) {
        self.sourceLanguage = sourceLanguage
        self.translationLanguage = translationLanguage
        self.hostLanguage = hostLanguage
    }

    public func translationURL(from originalURL: URL) -> URL? {
        guard var components = URLComponents(url: originalURL, resolvingAgainstBaseURL: false),
              let host = components.host
        else {
            return nil
        }

        components.host = host.replacingOccurrences(of: ".", with: "-") + ".translate.goog"

        components.queryItems = (components.queryItems ?? []) + [
            .init(name: "_x_tr_sl", value: sourceLanguage),
            .init(name: "_x_tr_tl", value: translationLanguage),
            .init(name: "_x_tr_hl", value: hostLanguage),
            .init(name: "_x_tr_pto", value: "wapp"),
        ]

        return components.url
    }
}

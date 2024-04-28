import Foundation

enum InputType {
    case url(URL)
    case query(String)
}

func guessInputType(text: String) -> InputType {
    let spaceRegex = try! Regex(#"\s"#)
    if text.contains(spaceRegex) {
        return .query(text)
    }

    let httpRegex = try! Regex("^https?://")
    if text.contains(httpRegex), let url = URL(string: text) {
        return .url(url)
    }

    return .query(text)
}

public func buildSearchURL(text: String) -> URL? {
    switch guessInputType(text: text) {
    case let .url(url):
        return url

    case let .query(text):
        var urlComponents = URLComponents(string: "https://www.google.com/search")!
        urlComponents.queryItems = [URLQueryItem(name: "q", value: text)]

        return urlComponents.url
    }
}

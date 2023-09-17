import Foundation

func buildSearchURL(text: String) -> URL? {
    if let url = URL(string: text) {
        return url
    }

    var urlComponents = URLComponents(string: "https://www.google.com/search")!
    urlComponents.queryItems = [URLQueryItem(name: "q", value: text)]

    return urlComponents.url
}

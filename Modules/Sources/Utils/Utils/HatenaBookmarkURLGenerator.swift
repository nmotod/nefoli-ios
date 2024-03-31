import Foundation

public struct HatenaBookmarkURLGenerator {
    public init() {}

    public func entryURL(of url: URL) -> URL? {
        var components = URLComponents(string: "https://b.hatena.ne.jp/")!

        let pathPrefix = (url.scheme == "https") ? "/entry/s/" : "/entry/"

        components.path = pathPrefix + (url.host() ?? "") + url.path(percentEncoded: false)
        components.query = url.query(percentEncoded: false)
        components.fragment = url.fragment(percentEncoded: false)

        return components.url
    }
}

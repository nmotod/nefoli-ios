import Foundation

public enum InternalURL: String {
    public static let scheme = "internal"
    public static let host = "internal"

    case home = "/home"

    public init?(url: URL) {
        if url.scheme != Self.scheme {
            return nil
        }

        switch url.path() {
        case Self.home.rawValue:
            self = .home

        default:
            return nil
        }
    }

    public var path: String { rawValue }

    public var url: URL {
        return URL(string: Self.scheme + "://" + Self.host + path)!
    }

    public static func isInternalURL(_ url: URL) -> Bool {
        return InternalURL(url: url) != nil
    }
}

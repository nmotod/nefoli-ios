import Foundation

enum InternalURL: String {
    static let scheme = "internal"
    static let host = "internal"

    case home = "/home"

    init?(url: URL) {
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

    var path: String { rawValue }

    var url: URL {
        return URL(string: Self.scheme + "://" + Self.host + path)!
    }
}

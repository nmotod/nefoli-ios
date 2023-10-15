import Foundation
import RealmSwift

public enum BookmarkItemID: CustomPersistable, CustomStringConvertible {
    public typealias PersistedType = String

    case favorites
    case bookmarks
    case regular(String)

    public init(persistedValue: String) {
        switch persistedValue {
        case Self.favorites.persistableValue:
            self = .favorites

        case Self.bookmarks.persistableValue:
            self = .bookmarks

        default:
            self = .regular(persistedValue)
        }
    }

    public var persistableValue: String {
        switch self {
        case .favorites:
            return "favorites"

        case .bookmarks:
            return "bookmarks"

        case let .regular(id):
            return id
        }
    }

    public var description: String { persistableValue }
}

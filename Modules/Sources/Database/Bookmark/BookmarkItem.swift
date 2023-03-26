import Foundation
import RealmSwift

/// The bookmark item that is a folder or bookmark.
///
/// Inherit Object because cycles containing embedded objects are not currently supported.
/// (RealmSwift 10.33.0)
public class BookmarkItem: Object, CreatedDateStorable, Identifiable {
    public enum Kind: String, PersistableEnum {
        case bookmark
        case folder
    }

    @Persisted(primaryKey: true) public var id = BookmarkItemID.regular(UUID().uuidString)

    @Persisted public var kind: Kind = .bookmark

    public var isFolder: Bool { kind == .folder }

    public var isBookmark: Bool { kind == .bookmark }

    @Persisted public var title: String

    public var localizedTitle: String {
        switch id {
        case .favorites:
            return NSLocalizedString("Favorites", comment: "")

        case .bookmarks:
            return NSLocalizedString("Bookmarks", comment: "")

        default:
            return title
        }
    }

    @Persisted public var url: URL?

    @Persisted public var children: List<BookmarkItem>

    @Persisted public var createdDate = Date.now

    @Persisted public var remoteIconExists: Bool?

    @Persisted(originProperty: "children") var parents: LinkingObjects<BookmarkItem>

    public var parent: BookmarkItem? { parents.first }
}

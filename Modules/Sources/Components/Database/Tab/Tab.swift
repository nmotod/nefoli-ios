import Foundation
import RealmSwift
import WebKit

public class Tab: Object, CreatedDateStorable, PropertyIterable {
    public enum Property: String, CaseIterable {
        case id
        case initialURL
        case createdDate
        case sessionState
        case lastURL
        case lastTitle
    }

    @Persisted(primaryKey: true) public var id = UUID().uuidString

    @Persisted public var initialURL: URL?

    // WKWebView#interactionState
    @Persisted public var sessionState: Data?

    @Persisted public internal(set) var lastURL: URL?

    @Persisted public internal(set) var lastTitle: String?

    @Persisted public private(set) var createdDate: Date = .init()

    @Persisted(originProperty: "children") private var parentGroups: LinkingObjects<TabGroup>

    public var group: TabGroup? { parentGroups.first }

    public convenience init(initialURL: URL) {
        self.init()
        self.initialURL = initialURL
    }
}

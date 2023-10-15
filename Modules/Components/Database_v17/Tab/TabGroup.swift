import Foundation
import RealmSwift

public class TabGroup: EmbeddedObject, Identifiable, CreatedDateStorable, PropertyIterable {
    public enum Property: String, CaseIterable {
        case id
        case children
        case activeTabId
        case createdDate
    }

    @Persisted public private(set) var id: String = UUID().uuidString

    @Persisted public private(set) var children: List<Tab>

    @Persisted public var activeTabId: String?

    @Persisted public private(set) var createdDate: Date = .init()
}

extension TabGroup {
    public var activeTabIndex: Int? {
        get {
            guard let activeTabId = activeTabId else {
                return nil
            }

            return children.firstIndex { tab in
                tab.id == activeTabId
            }
        }

        set {
            if let index = newValue {
                activeTabId = children[index].id
            } else {
                activeTabId = nil
            }
        }
    }
}

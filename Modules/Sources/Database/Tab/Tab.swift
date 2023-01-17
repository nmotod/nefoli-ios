import Foundation
import RealmSwift
import WebKit

public class Tab: EmbeddedObject, CreatedDateStorable, PropertyIterable {
    public enum Property: String, CaseIterable {
        case id
        case historyItems
        case initialURL
        case createdDate
    }

    @Persisted public var id = UUID().uuidString

    @Persisted public var initialURL: URL?

    @Persisted public private(set) var backList: List<BackForwardListItem>
    
    @Persisted public private(set) var forwardList: List<BackForwardListItem>
    
    @Persisted public private(set) var current: BackForwardListItem?

    @Persisted public private(set) var createdDate: Date = .init()

    @Persisted(originProperty: "children") private var parentGroups: LinkingObjects<TabGroup>

    public var group: TabGroup? { parentGroups.first }

    public convenience init(initialURL: URL) {
        self.init()
        self.initialURL = initialURL
    }

    public func updateBackForwardList(wkBackForwardList: WKBackForwardList) {
        if let currentItem = wkBackForwardList.currentItem {
            current = .init(wkItem: currentItem)
        }
        
        backList.removeAll()
        backList.append(objectsIn: wkBackForwardList.backList.map(BackForwardListItem.init(wkItem:)))
        
        forwardList.removeAll()
        forwardList.append(objectsIn: wkBackForwardList.forwardList.map(BackForwardListItem.init(wkItem:)))
    }
}

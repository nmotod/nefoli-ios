import Foundation
import RealmSwift

public class Tab: EmbeddedObject, CreatedDateStorable, PropertyIterable {
    public enum Property: String, CaseIterable {
        case id
        case historyItems
        case initialURL
        case createdDate
    }
    
    @Persisted public var id = UUID().uuidString
    
    @Persisted public var historyItems: List<HistoryItem>
    
    public var current: HistoryItem? { historyItems.last }
    
    @Persisted public var initialURL: URL?
    
    @Persisted public private(set) var createdDate: Date = .init()
    
    @Persisted(originProperty: "children") private var parentGroups: LinkingObjects<TabGroup>
    
    public var group: TabGroup? { parentGroups.first }
    
    public convenience init(initialURL: URL) {
        self.init()
        self.initialURL = initialURL
    }
}

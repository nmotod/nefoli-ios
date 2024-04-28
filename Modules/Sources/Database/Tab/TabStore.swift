import Foundation
import RealmSwift

public protocol UsesTabStore {
    var tabStore: TabStore { get }
}

public protocol TabStore: AnyObject {
    var groups: List<TabGroup> { get }

    var closedTabs: List<Tab> { get }

    /// - Note: may only be called during a Realm write transaction.
//    func removeClosedTab(at index: Int) {
//        _closedTabs.remove(at: index)
//    }
}

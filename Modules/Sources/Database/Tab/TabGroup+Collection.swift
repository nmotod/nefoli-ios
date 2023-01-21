import Foundation
import RealmSwift

extension TabGroup: Collection {
    public typealias Element = Tab
    public typealias Index = Int

    public var startIndex: Int { children.startIndex }

    public var endIndex: Int { children.endIndex }

    public func index(after i: Int) -> Int {
        return children.index(after: i)
    }

    public subscript(position: Int) -> Tab {
        return children[position]
    }
}

extension TabGroup {
    public func move(from: Int, to: Int) {
        children.move(from: from, to: to)
    }

    public func observeChildren(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (RealmCollectionChange<List<Tab>>) -> Void
    ) -> NotificationToken {
        return children.observe(on: queue, block)
    }
}

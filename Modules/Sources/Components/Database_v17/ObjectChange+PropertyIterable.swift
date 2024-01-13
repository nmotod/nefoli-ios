import Foundation
import RealmSwift

extension ObjectChange where T: PropertyIterable {
    public var changedProperties: [T.Property]? {
        guard case let .change(_, changes) = self else {
            return nil
        }

        return changes.compactMap { T.Property(rawValue: $0.name) }
    }
}

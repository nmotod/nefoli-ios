import Foundation
import RealmSwift

// @see https://www.mongodb.com/docs/realm-sdks/swift/latest/Protocols/CustomPersistable.html
extension URL: FailableCustomPersistable {
    public typealias PersistedType = String
    
    public init?(persistedValue: String) {
        self.init(string: persistedValue)
    }

    public var persistableValue: PersistedType {
        absoluteString
    }
}

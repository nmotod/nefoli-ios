import Foundation
import RealmSwift

public class HistoryItem: EmbeddedObject {
    @Persisted public var title = ""
    @Persisted public var url: URL?
}

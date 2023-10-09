import Foundation
import RealmSwift

public class ContentFilterSetting: EmbeddedObject, Identifiable {
    @Persisted public private(set) var id: String = UUID().uuidString
    @Persisted public var name: String
    @Persisted public var sourceURL: URL?
    @Persisted public var sourceID: String?
    @Persisted public var isEnabled = true

    public convenience init(
        name: String,
        sourceURL: URL? = nil,
        sourceID: String? = nil
    ) {
        self.init()

        self.name = name
        self.sourceURL = sourceURL
        self.sourceID = sourceID
    }
}

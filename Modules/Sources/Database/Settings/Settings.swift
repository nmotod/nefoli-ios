import Foundation
import RealmSwift

public protocol UsesSettings {
    var settings: Settings { get }
}

public class Settings: EmbeddedObject, ObjectKeyIdentifiable {
    @Persisted public var id = UUID().uuidString
    @Persisted public var contentFilterSettings: List<ContentFilterSetting>
}

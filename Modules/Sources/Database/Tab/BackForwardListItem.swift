import Foundation
import RealmSwift
import WebKit

public class BackForwardListItem: EmbeddedObject {
    @Persisted public var title = ""
    @Persisted public var url: URL?

    convenience init(wkItem: WKBackForwardListItem) {
        self.init()

        title = wkItem.title ?? ""
        url = wkItem.url
    }

    convenience init(title: String, url: URL?) {
        self.init()

        self.title = title
        self.url = url
    }
}

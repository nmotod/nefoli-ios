import Foundation
import os.log

let moduleIdentifier = "app.nefoli.Database"

extension Logger {
    init(category: String) {
        self.init(subsystem: moduleIdentifier, category: category)
    }
}

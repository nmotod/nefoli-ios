import Foundation
import NFLDatabase

extension Tab: ScreenshotSource {
    var screenshotKey: String { id }

    var internalURL: InternalURL? {
        guard let url = current?.url else {
            return nil
        }

        return InternalURL(url: url)
    }
}

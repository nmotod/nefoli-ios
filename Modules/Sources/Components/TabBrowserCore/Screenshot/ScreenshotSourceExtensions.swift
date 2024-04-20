import Database
import Foundation

extension Tab: ScreenshotSource {
    public var screenshotKey: String { id }

    public var internalURL: InternalURL? {
        guard let lastURL else {
            return nil
        }

        return InternalURL(url: lastURL)
    }
}

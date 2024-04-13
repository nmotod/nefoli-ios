import Foundation

public protocol ScreenshotSource {
    var screenshotKey: String { get }

    var internalURL: InternalURL? { get }
}

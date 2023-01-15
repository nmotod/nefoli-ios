import Database
import UIKit
import WebKit

extension Notification.Name {
    static var nfl_screenshotDidUpdate = Notification.Name("nfl_screenshotDidUpdate")
}

public protocol UsesScreenshotManager {
    var screenshotManager: ScreenshotManager { get }
}

public class ScreenshotManager {
    typealias UpdateHandler = (String, UIView) -> Void

    var screenshotSize = CGSize(width: 250, height: 250 * 3)

    private let storage: ScreenshotCacheStorage

    private let notificationCenter = NotificationCenter.default

    private var tokens: [NSObjectProtocol] = []

    public init(
        screenshotSize: CGSize,
        cachesDirectoryURL: URL
    ) {
        self.screenshotSize = screenshotSize

        storage = ScreenshotCacheStorage(cachesDirectoryURL: cachesDirectoryURL)

        // TODO: observe Tab deletion
    }

    func updateScreenshot(sources: [ScreenshotSource], webView: WKWebView) {
        if let url = webView.url,
           let internalURL = InternalURL(url: url),
           let view = createInternalScreenshotView(internalURL: internalURL)
        {
            Task { @MainActor in
                for source in sources {
                    self.notificationCenter.post(name: .nfl_screenshotDidUpdate, object: self, userInfo: [
                        "key": source.screenshotKey,
                        "view": view,
                    ])
                }
            }

        } else {
            takeScreenshot(sources: sources, webView: webView)
        }
    }

    private func takeScreenshot(sources: [ScreenshotSource], webView: WKWebView) {
        let screenshotConfig = WKSnapshotConfiguration()
        screenshotConfig.afterScreenUpdates = true

        screenshotConfig.rect = CGRect(origin: CGPoint(x: 0, y: webView.scrollView.adjustedContentInset.top),
                                       size: screenshotSize)

        webView.takeSnapshot(with: screenshotConfig, completionHandler: { [weak self] image, error in
            guard let self = self else { return }

            if let image = image {
                self.didTakeScreenshot(sources: sources, image: image)

            } else if let error = error {
                print(error)
            }
        })
    }

    private func didTakeScreenshot(sources: [ScreenshotSource], image: UIImage) {
        for source in sources {
            try! storage.save(image: image, for: source)
        }

        let imageView = createImageView(image: image)

        Task { @MainActor in
            for source in sources {
                self.notificationCenter.post(name: .nfl_screenshotDidUpdate, object: self, userInfo: [
                    "key": source.screenshotKey,
                    "view": imageView,
                ])
            }
        }
    }

    func getContentView(source: ScreenshotSource) -> UIView? {
        if let internalURL = source.internalURL,
           let view = createInternalScreenshotView(internalURL: internalURL)
        {
            return view

        } else if let image = storage.load(source: source) {
            return createImageView(image: image)
        }

        return nil
    }

    private func createInternalScreenshotView(internalURL: InternalURL) -> UIView? {
        switch internalURL {
        case .home:
            return HomeScreenshotContentView()
        }
    }

    private func createImageView(image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)

        imageView.autoresizingMask = []

        // Improve the quality of reduced image.
        // https://stackoverflow.com/a/12742944
        imageView.layer.minificationFilter = .trilinear

        return imageView
    }

    /// Observes screenshot updates.
    /// - Parameter handler: The handler that invoked in main thread.
    /// - Returns: The notification token.
    func observeUpdate(handler: @escaping UpdateHandler) -> NSObjectProtocol {
        return notificationCenter.addObserver(forName: .nfl_screenshotDidUpdate, object: self, queue: nil) { note in
            if let key = note.userInfo?["key"] as? String,
               let view = note.userInfo?["view"] as? UIView
            {
                handler(key, view)
            }
        }
    }

    private func tabWillDelete(tab: Tab) {
        try! storage.delete(source: tab)
    }
}

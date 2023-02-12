import Database
import Foundation
import WebKit

public protocol UsesWebViewManager {
    var webViewManager: WebViewManager { get }
}

@MainActor
public class WebViewManager {
    private let internalURLSchemeHandler = InternalURLSchemeHandler()

    private let settings: Settings

    private var tokens = [NotificationToken]()

    public init(
        settings: Settings
    ) {
        self.settings = settings
    }

    private lazy var userContentControllerBootstrap = Task { @MainActor in
        let controller = WKUserContentController()

        return controller
    }

    func getWebView(frame: CGRect) async -> WKWebView {
        let webView = await Task { @MainActor in
            let configuration = WKWebViewConfiguration()

            configuration.userContentController = try! await userContentControllerBootstrap.value

            // Ignore <meta name="viewport" content="user-scalable=no">
            configuration.ignoresViewportScaleLimits = true

            configuration.setURLSchemeHandler(internalURLSchemeHandler, forURLScheme: InternalURL.scheme)

            let webView = WKWebView(frame: frame, configuration: configuration)

            webView.allowsBackForwardNavigationGestures = true
            webView.scrollView.contentInsetAdjustmentBehavior = .always

            return webView
        }.value

        return webView
    }

    func handlesURLScheme(_ scheme: String) -> Bool {
        return WKWebView.handlesURLScheme(scheme)
            || scheme == InternalURL.scheme
    }
}

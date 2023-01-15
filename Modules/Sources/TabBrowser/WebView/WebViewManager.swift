import Foundation
import WebKit

public protocol UsesWebViewManager {
    var webViewManager: WebViewManager { get }
}

public class WebViewManager {
    private let internalURLSchemeHandler = InternalURLSchemeHandler()

    public init() {}

    func getWebView(frame: CGRect) async -> WKWebView {
        let webView = await MainActor.run {
            let configuration = WKWebViewConfiguration()

            // Ignore <meta name="viewport" content="user-scalable=no">
            configuration.ignoresViewportScaleLimits = true

            configuration.setURLSchemeHandler(internalURLSchemeHandler, forURLScheme: InternalURL.scheme)

            let webView = WKWebView(frame: frame, configuration: configuration)

            webView.allowsBackForwardNavigationGestures = true
            webView.scrollView.contentInsetAdjustmentBehavior = .always

            return webView
        }

        return webView
    }

    func handlesURLScheme(_ scheme: String) -> Bool {
        return WKWebView.handlesURLScheme(scheme)
            || scheme == InternalURL.scheme
    }
}

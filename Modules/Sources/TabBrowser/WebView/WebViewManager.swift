import ContentBlocker
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

    private let contentFilterManager: ContentFilterManager

    private var tokens = [NotificationToken]()

    public init(
        settings: Settings,
        contentFilterManager: ContentFilterManager
    ) {
        self.settings = settings
        self.contentFilterManager = contentFilterManager

        tokens.append(contentFilterManager.observeFilters { [weak self] in
            guard let self else { return }

            Task { @MainActor in
                let controller = try! await self.userContentControllerBootstrap.value
                try! await self.contentFilterManager.reloadFilters(userContentController: controller)
            }
        })
    }

    private lazy var userContentControllerBootstrap = Task { @MainActor in
        let controller = WKUserContentController()

        try await contentFilterManager.reloadFilters(userContentController: controller)

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

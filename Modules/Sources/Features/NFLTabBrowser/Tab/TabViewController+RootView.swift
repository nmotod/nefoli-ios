import Foundation
import NFLThemeSystem
import UIKit
import WebKit

extension TabViewController {
    class RootView: UIView {
        private weak var webView: WKWebView?

        func showWebView(_ webView: WKWebView) {
            self.webView = webView

            insertSubview(webView, at: 0)
            webView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}

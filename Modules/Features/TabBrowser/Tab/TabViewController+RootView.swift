import Foundation
import ThemeSystem
import UIKit
import WebKit

extension TabViewController {
    class RootView: UIView {
        let topBarBackgroundView = UIVisualEffectView(effect: Effects.barBackground)

        private weak var webView: WKWebView?

        override init(frame: CGRect) {
            super.init(frame: frame)

            addSubview(topBarBackgroundView)

            topBarBackgroundView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(safeAreaLayoutGuide.snp.top)
            }
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func showWebView(_ webView: WKWebView) {
            self.webView = webView

            insertSubview(webView, at: 0)
            webView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}

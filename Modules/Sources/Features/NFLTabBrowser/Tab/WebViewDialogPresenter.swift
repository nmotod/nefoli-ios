import Foundation
import UIKit
import WebKit

class WebViewDialogPresenter {
    private(set) weak var viewController: UIViewController?

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alert.addAction(.init(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            completionHandler()
        })

        viewController?.present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alert.addAction(.init(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
            completionHandler(true)
        })

        alert.addAction(.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            completionHandler(false)
        })

        viewController?.present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.text = defaultText
        }

        alert.addAction(.init(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak alert] _ in
            guard let alert else { return }

            completionHandler(alert.textFields![0].text)
        })

        alert.addAction(.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            completionHandler(nil)
        })

        viewController?.present(alert, animated: true)
    }
}

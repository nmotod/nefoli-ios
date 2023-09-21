import Foundation

extension TabViewController {
    func execute(command: TabCommand, sender: Any?) {
        switch command {
        case .goBack:
            webView?.goBack()

        case .goForward:
            webView?.goForward()

        case .reload:
            webView?.reload()

        case .share:
            share(sender)

        case .openInDefaultApp:
            openInDefaultApp()

        case .addBookmark:
            ()

        case .editAddress:
            editAddress(sender)
        }
    }
}

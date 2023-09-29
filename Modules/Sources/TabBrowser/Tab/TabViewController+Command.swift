import Foundation

extension TabViewController {
    func execute(command: TabCommand, sender: Any?) {
        switch command {
        case .goBack:
            goBack(sender)

        case .goForward:
            goForward(sender)

        case .reload:
            reload(sender)

        case .share:
            share(sender)

        case .openInDefaultApp:
            openInDefaultApp()

        case .addBookmark:
            addBookmark(sender)

        case .editAddress:
            editAddress(sender)
        }
    }
}

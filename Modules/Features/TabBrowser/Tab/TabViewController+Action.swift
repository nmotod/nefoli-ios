import Foundation

extension TabViewController {
    func performAction(type actionType: TabActionType, sender: Any?) {
        switch actionType {
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

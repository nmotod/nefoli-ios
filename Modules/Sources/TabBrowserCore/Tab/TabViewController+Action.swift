import ActionSystem
import Foundation
import ThemeSystem
import UIKit

extension TabViewController: ActionDispatcher {
    public func canDispatchAction(type: any ActionTypeProtocol) -> Bool {
        return type is TabActionType || type is CustomActionType
    }

    public func dispatchAnyAction(type actionType: any ActionTypeProtocol, sender: Any?) throws {
        if let actionType = actionType as? TabActionType {
            performAction(type: actionType, sender: sender)

        } else if let actionType = actionType as? CustomActionType {
            performCustomAction(type: actionType, sender: sender)

        } else {
            throw ActionDispatchError.unsupported
        }
    }

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

        case .translate:
            translate(sender)

        case .hatenaBookmark:
            openHatenaBookmark(sender)
        }
    }

    // TODO: support long press
    public func makeOmnibarButton(type actionType: TabActionType) -> UIButton? {
        guard let uiAction = makeUIAction(type: actionType) else {
            return nil
        }

        let button = Omnibar.makeOmnibarButton(primaryAction: uiAction)

        switch actionType {
        case .goBack:
            button.nfl_syncIsEnabled(publisher: canGoBackPublisher)
            button.menu = makeBackForwardMenu()

        case .goForward:
            button.nfl_syncIsEnabled(publisher: canGoForwardPublisher)
            button.menu = makeBackForwardMenu()

        default: ()
        }

        return button
    }
}

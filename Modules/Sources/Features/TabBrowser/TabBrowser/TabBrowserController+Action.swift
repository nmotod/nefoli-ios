import ActionSystem
import Foundation
import TabBrowserCore
import ThemeSystem
import UIKit

private func makeButton(primaryAction: UIAction) -> UIButton {
    primaryAction.title = ""

    let button = UIButton(primaryAction: primaryAction)
    button.tintColor = ThemeColors.tint.color
    button.snp.makeConstraints { make in
        make.width.equalTo(44)
    }

    return button
}

extension TabBrowserController: ActionDispatcher {
    public class func supportedActionTypes() -> [any ActionTypeProtocol] {
        return TabBrowserActionType.allCases + TabActionType.allCases
    }

    public func canDispatchAction(type: any ActionTypeProtocol) -> Bool {
        if type is TabBrowserActionType {
            return true

        } else if let activeVC {
            return activeVC.canDispatchAction(type: type)
        }

        return false
    }

    func performAction(type actionType: TabBrowserActionType, sender: Any?) {
        switch actionType {
        case .bookmarks:
            showBookmarks(sender)

        case .closeActiveTab:
            closeActiveTab()

        case .menuSheet:
            showMenuSheet()

        case .tabs:
            ()

        case .settings:
            showSettings(sender)

        case .restoreClosedTab:
            restoreClosedTab(sender)

        case .debugEditBookmark:
            ()
        }
    }

    public func dispatchAnyAction(type actionType: any ActionTypeProtocol, sender: Any?) throws {
        if let actionType = actionType as? TabBrowserActionType {
            performAction(type: actionType, sender: sender)

        } else if let activeVC, activeVC.canDispatchAction(type: actionType) {
            try activeVC.dispatchAnyAction(type: actionType, sender: sender)

        } else {
            throw ActionDispatchError.unsupported
        }
    }

    // TODO: support long press
    func makeActionButton(type actionType: TabBrowserActionType) -> UIButton? {
        guard let uiAction = makeUIAction(type: actionType) else {
            return nil
        }

        return makeButton(primaryAction: uiAction)
    }

    func makeTabActionButton(type actionType: TabActionType, for tabVC: TabViewController) -> UIButton? {
        guard let uiAction = tabVC.makeUIAction(type: actionType) else {
            return nil
        }

        let button = makeButton(primaryAction: uiAction)

        switch actionType {
        case .goBack:
            button.nfl_syncIsEnabled(publisher: tabVC.canGoBackPublisher)

        case .goForward:
            button.nfl_syncIsEnabled(publisher: tabVC.canGoForwardPublisher)

        default: ()
        }

        return button
    }
}

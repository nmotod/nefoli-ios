import ActionSystem
import Foundation
import ThemeSystem
import UIKit

extension TabBrowserController {
    public enum ActionError: Error {
        case unsupported
    }

    public class func supportedActionTypes() -> [any ActionTypeProtocol] {
        return TabBrowserActionType.allCases + TabActionType.allCases
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

        } else if let actionType = actionType as? TabActionType {
            activeVC?.performAction(type: actionType, sender: sender)

        } else if let actionType = actionType as? CustomActionType {
            activeVC?.performCustomAction(type: actionType, sender: sender)

        } else {
            throw ActionError.unsupported
        }
    }

    func makeUIAction(type actionType: any ActionTypeProtocol) -> UIAction? {
        return actionType.makeUIAction { [weak self] uiAction in
            guard let self else { return }

            try! self.dispatchAnyAction(type: actionType, sender: uiAction.sender)
        }
    }

    // TODO: support long press
    func makeButton(actionType: any ActionTypeProtocol) -> UIButton? {
        guard let uiAction = makeUIAction(type: actionType) else {
            return nil
        }

        uiAction.title = ""

        let button = UIButton(primaryAction: uiAction)
        button.tintColor = ThemeColors.tint.color
        button.snp.makeConstraints { make in
            make.width.equalTo(44)
        }

        if let activeVC, let action = actionType as? TabActionType {
            switch action {
            case .goBack:
                button.nfl_syncIsEnabled(publisher: activeVC.canGoBackPublisher)

            case .goForward:
                button.nfl_syncIsEnabled(publisher: activeVC.canGoForwardPublisher)

            default: ()
            }
        }

        return button
    }
}

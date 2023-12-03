import Foundation
import UIKit

public enum ActionDispatchError: Error {
    case unsupported
}

public protocol ActionDispatcher {
    func canDispatchAction(type: any ActionTypeProtocol) -> Bool

    func dispatchAnyAction(type actionType: any ActionTypeProtocol, sender: Any?) throws
}

extension ActionDispatcher where Self: AnyObject {
    public func makeUIAction(type actionType: any ActionTypeProtocol) -> UIAction? {
        return actionType.makeUIAction { [weak self] uiAction in
            guard let self else { return }

            try! self.dispatchAnyAction(type: actionType, sender: uiAction.sender)
        }
    }
}

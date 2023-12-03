import Foundation
import UIKit

extension UIResponder {
    public func nfl_findResponder<T: UIResponder>(of type: T.Type) -> T? {
        var responder: UIResponder? = next

        while responder != nil {
            if let vc = responder as? T {
                return vc
            }

            responder = responder?.next
        }

        return nil
    }
}

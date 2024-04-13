import Combine
import Foundation
import ObjectiveC
import UIKit

public protocol IsEnabledSynchronizable {
    var isEnabled: Bool { get set }

    func nfl_syncIsEnabled<P: Publisher>(publisher: P) where P.Output == Bool, P.Failure == Never
}

private enum AssociatedObjectKeys {
    static var cancellable: Int8 = 0
}

extension IsEnabledSynchronizable where Self: NSObject {
    public func nfl_syncIsEnabled<P: Publisher>(publisher: P) where P.Output == Bool, P.Failure == Never {
        let cancellable = publisher.sink { [weak self] newValue in
            self?.isEnabled = newValue
        }

        objc_setAssociatedObject(self, &AssociatedObjectKeys.cancellable, cancellable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension UIControl: IsEnabledSynchronizable {}
extension UIBarButtonItem: IsEnabledSynchronizable {}

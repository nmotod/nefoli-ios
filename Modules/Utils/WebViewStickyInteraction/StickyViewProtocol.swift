import Foundation
import UIKit

public protocol StickyViewProtocol: AnyObject where Self: UIView {
    var maxHeight: CGFloat { get }
    var minHeight: CGFloat { get }
    var currentPercentHidden: CGFloat { get set }
    var currentHiddenHeight: CGFloat { get }
}

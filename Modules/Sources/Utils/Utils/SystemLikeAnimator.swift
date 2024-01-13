import UIKit

public class SystemLikeAnimator {
    public static let defaultDuration: TimeInterval = 0.5

    public class func animate(
        withDuration duration: TimeInterval = defaultDuration,
        options _: UIView.AnimationOptions = [],
        animations: @escaping () -> Void
    ) {
        animate(withDuration: duration, animations: animations, completion: nil)
    }

    public class func animate(
        withDuration duration: TimeInterval = defaultDuration,
        options: UIView.AnimationOptions = [],
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        /// see: https://qiita.com/usagimaru/items/4306f261457e82641e4a
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: options,
                       animations: animations,
                       completion: completion)
    }
}

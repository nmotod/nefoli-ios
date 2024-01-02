import Foundation
import WebKit

private let WKWebView_setStickyInsets: ((AnyObject, UIEdgeInsets) -> Void)? = {
    let sel = Selector(String(format: "_set%@uredInsets:", "Obsc"))

    guard let imp = WKWebView.instanceMethod(for: sel) else { return nil }

    let f = unsafeBitCast(imp, to: (@convention(c) (AnyObject, Selector, UIEdgeInsets) -> Void).self)

    return { (self, insets) in
        f(self, sel, insets)
    }
}()

private let WKWebview_setCSSSafeAreaInsets: ((AnyObject, UIEdgeInsets) -> Void)? = {
    let sel = Selector(String(format: "_set%@curedSafeAreaInsets:", "Unobs"))

    guard let imp = WKWebView.instanceMethod(for: sel) else { return nil }

    let f = unsafeBitCast(imp, to: (@convention(c) (AnyObject, Selector, UIEdgeInsets) -> Void).self)

    return { (self, insets) in
        f(self, sel, insets)
    }
}()

extension WKWebView {
    public func nfl_setStickyInsets(_ insets: UIEdgeInsets) {
        WKWebView_setStickyInsets?(self, insets)
    }

    public func nfl_setCSSSafeAreaInsets(_ insets: UIEdgeInsets) {
        WKWebview_setCSSSafeAreaInsets?(self, insets)
    }
}

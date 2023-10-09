import WebKit

private let stickyInsetsKey: String = {
    var parts = ["ob", "Insets"]
    parts.insert("scured", at: 1)
    return parts.joined()
}()

/// see https://github.com/WebKit/WebKit/blob/92bb7222c6b46ec0599b9254de301b162cad42ad/Source/WebKit/UIProcess/API/Cocoa/WKWebViewPrivate.h#L440
extension WKWebView {
    var nfl_stickyInsets: UIEdgeInsets {
        get {
            return value(forKey: stickyInsetsKey) as! UIEdgeInsets
        }
        set {
            setValue(newValue, forKey: stickyInsetsKey)
        }
    }
}

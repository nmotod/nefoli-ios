import WebKit

/// see https://stackoverflow.com/questions/38450586/prevent-universal-links-from-opening-in-wkwebview-uiwebview
/// see https://opensource.apple.com/source/WebKit2/WebKit2-7601.1.46.9/UIProcess/API/Cocoa/WKNavigationDelegatePrivate.h.auto.html
///
/// static const WKNavigationActionPolicy WK_AVAILABLE(WK_MAC_TBA, WK_IOS_TBA) _WKNavigationActionPolicyAllowWithoutTryingAppLink = (WKNavigationActionPolicy)(WKNavigationActionPolicyAllow + 2);
extension WKNavigationActionPolicy {
    static var allowWithoutTryingAppLink = WKNavigationActionPolicy(rawValue: WKNavigationActionPolicy.allow.rawValue + 2)!
}

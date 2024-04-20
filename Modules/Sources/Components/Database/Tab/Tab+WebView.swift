import WebKit

extension Tab {
    public func updateLastURLOrTitle(webView: WKWebView) {
        lastURL = webView.url
        lastTitle = webView.title
    }
}

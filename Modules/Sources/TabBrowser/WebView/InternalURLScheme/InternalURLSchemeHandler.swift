import Foundation
import WebKit

class InternalURLSchemeHandler: NSObject, WKURLSchemeHandler {
    func webView(_: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let html = """
        <!doctype html>
        <html>
        <head>
            <title>Internal</title>
        </head>
        <body>
        </body>
        </html>
        """
        
        let respones = URLResponse(
            url: urlSchemeTask.request.url!,
            mimeType: "text/html",
            expectedContentLength: html.lengthOfBytes(using: .utf8),
            textEncodingName: "UTF-8"
        )
        
        urlSchemeTask.didReceive(respones)
        urlSchemeTask.didReceive(html.data(using: .utf8)!)
        
        urlSchemeTask.didFinish()
    }

    func webView(_: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        urlSchemeTask.didFinish()
    }
}

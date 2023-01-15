import MobileCoreServices
import UIKit
import UniformTypeIdentifiers

enum ActionRequestHandlerError: Error {
    case invalidInput
    case urlBuildError(String)
}

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        for item in context.inputItems as! [NSExtensionItem] {
            if let attachments = item.attachments {
                for itemProvider in attachments {
                    if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                        itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier) { item, _ in
                            let url = item as! URL

                            DispatchQueue.main.async {
                                self.open(url: url)
                                context.completeRequest(returningItems: [], completionHandler: nil)
                            }
                        }
                        return

                    } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                        itemProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, _ in
                            let text = item as! String

                            DispatchQueue.main.async {
                                self.search(text: text)
                                context.completeRequest(returningItems: [], completionHandler: nil)
                            }
                        }
                        return
                    }
                }
            }
        }

        context.cancelRequest(withError: ActionRequestHandlerError.invalidInput)
    }

    private func open(url originalURL: URL) {
        var comps = URLComponents()
        comps.scheme = OpenInExtension.urlScheme()
        comps.host = "x-callback-url"
        comps.path = "/open"
        comps.queryItems = [
            URLQueryItem(name: "url", value: originalURL.absoluteString),
        ]

        OpenInExtension.open(comps.url!)
    }

    private func search(text: String) {
        var comps = URLComponents()
        comps.scheme = OpenInExtension.urlScheme()
        comps.host = "x-callback-url"
        comps.path = "/search"
        comps.queryItems = [
            URLQueryItem(name: "text", value: text),
        ]

        OpenInExtension.open(comps.url!)
    }
}

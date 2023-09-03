import Database
import Foundation
import TabBrowser
import UIKit

enum OpenURLError: Error, Equatable {
    case unsupportedURL
    case unknownAction(action: String)
    case missingRequiredParameter(missingParameter: String)
    case other(reson: String)
}

enum OpenURLAction: String {
    case open
    case search
}

/// http://x-callback-url.com/specifications/
class OpenURLHandler {
    let tabGroupController: TabGroupController
    let options: TabGroup.AddingOptions

    init(tabGroupController: TabGroupController, options: TabGroup.AddingOptions) {
        self.tabGroupController = tabGroupController
        self.options = options
    }

    func handle(openURL callbackURL: URL) -> OpenURLError? {
        switch callbackURL.host ?? "" {
        case "x-callback-url":
            return handle(xCallbackURL: callbackURL)

        default:
            return .unsupportedURL
        }
    }

    private func handle(xCallbackURL callbackURL: URL) -> OpenURLError? {
        let actionString = callbackURL.path.trimmingCharacters(in: CharacterSet(["/"]))
        guard let action = OpenURLAction(rawValue: actionString) else {
            return .unknownAction(action: actionString)
        }

        let queryItems = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true)?.queryItems ?? []

        switch action {
        case .open:
            return handleOpenAction(queryItems: queryItems)

        case .search:
            return handleSearchAction(queryItems: queryItems)
        }
    }

    private func handleOpenAction(queryItems: [URLQueryItem]) -> OpenURLError? {
        guard let urlString = queryItems.first(where: { $0.name == "url" })?.value else {
            return .missingRequiredParameter(missingParameter: "url")
        }

        guard let url = URL(string: urlString) else {
            return .other(reson: "invalid 'url' param")
        }

        let tab = Tab(initialURL: url)
        try! tabGroupController.open(tab: tab, options: options)
        return nil
    }

    private func handleSearchAction(queryItems: [URLQueryItem]) -> OpenURLError? {
        guard let text = queryItems.first(where: { $0.name == "text" })?.value else {
            return .missingRequiredParameter(missingParameter: "text")
        }

        guard var urlComponents = URLComponents(string: "https://www.google.com/search?ie=UTF-8") else {
            fatalError()
        }

        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(URLQueryItem(name: "q", value: text))
        urlComponents.queryItems = queryItems

        let tab = Tab(initialURL: urlComponents.url!)
        try! tabGroupController.open(tab: tab, options: options)
        return nil
    }
}

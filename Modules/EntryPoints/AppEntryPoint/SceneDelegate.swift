import RealmSwift
import TabBrowser
import UIKit
import Utils

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    var tabBrowserController: TabBrowserController?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
//        window.overrideUserInterfaceStyle = .dark

        var splashWindow: UIWindow? = UIWindow(windowScene: windowScene)
        splashWindow?.windowLevel = .normal + 1
        splashWindow?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: .main).instantiateInitialViewController()

        self.window = window

        splashWindow?.isHidden = false
        window.makeKeyAndVisible()

        Task<Void, Never> {
            let container = try! await RootContainerBootstrap.shared.container

            let g1 = container.rootState.groups.first

            let controller = TabBrowserController(group: g1, dependency: container)
            self.tabBrowserController = controller

            window.rootViewController = controller

            UIView.animate(withDuration: 0.3) {
                splashWindow?.alpha = 0
            } completion: { _ in
                splashWindow = nil
            }

            if !connectionOptions.urlContexts.isEmpty {
                handleOpenURL(urlContexts: connectionOptions.urlContexts)
            }

            #if DEBUG
            try! executeDebugAction()
            #endif
        }
    }

    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        handleOpenURL(urlContexts: URLContexts)
    }

    private func handleOpenURL(urlContexts: Set<UIOpenURLContext>) {
        guard let tabBrowserController else {
            return
        }

        let handler = OpenURLHandler(
            tabBrowserController: tabBrowserController,
            options: .init(activate: true, position: .end)
        )

        for context in urlContexts {
            if let error = handler.handle(openURL: context.url) {
                let alert = UIAlertController(
                    title: NSLocalizedString("Cannot open URL", comment: ""),
                    // TODO: message
                    message: "\(String(describing: error)) \(context.url)",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))

                tabBrowserController.present(alert, animated: true)
                break
            }
        }
    }

    #if DEBUG
    private func executeDebugAction() throws {
        guard amIBeingDebugged(),
              let tabGroupController = tabBrowserController,
              let id = ProcessInfo.processInfo.environment["NFL_DEBUG_ACTION"],
              let actionType = TabBrowserController.supportedActionTypes().first(where: { $0.id == id })
        else {
            return
        }

        try tabGroupController.dispatchAnyAction(type: actionType, sender: nil)
    }
    #endif
}

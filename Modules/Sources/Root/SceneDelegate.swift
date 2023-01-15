import TabBrowser
import UIKit
import Utilities

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    var tabGroupController: TabGroupController?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
//        window.overrideUserInterfaceStyle = .dark

        var splashWindow: UIWindow? = UIWindow(windowScene: windowScene)
        splashWindow?.windowLevel = .normal + 1
        splashWindow?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: .main).instantiateInitialViewController()

        Task {
            let container = try await RootContainerBootstrap.shared.container

            await MainActor.run {
                let g1 = container.rootState.groups.first

                let controller = TabGroupController(group: g1, dependency: container)
                self.tabGroupController = controller

                window.rootViewController = controller

                UIView.animate(withDuration: 0.3) {
                    splashWindow?.alpha = 0
                } completion: { _ in
                    splashWindow = nil
                }

                #if DEBUG
                executeDebugAction()
                #endif
            }
        }

        self.window = window

        splashWindow?.isHidden = false
        window.makeKeyAndVisible()

        if !connectionOptions.urlContexts.isEmpty {
//            handleOpenURL(urlContexts: connectionOptions.urlContexts)
        }
    }

    #if DEBUG
    private func executeDebugAction() {
        guard amIBeingDebugged(),
              let tabGroupController = tabGroupController,
              let id = ProcessInfo.processInfo.environment["NFL_DEBUG_ACTION"],
              let action = TabGroupController.supportedActions().first(where: { $0.identifier == id })
        else {
            return
        }

        let executable = tabGroupController.executableAction(action: action)
        executable?.execute()
    }
    #endif
}

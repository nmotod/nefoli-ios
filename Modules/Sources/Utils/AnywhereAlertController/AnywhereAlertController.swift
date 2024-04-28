import UIKit

/// An alert controller that can be presented without a parent view controller.
public class AnywhereAlertController: UIAlertController {
    private class RootViewController: UIViewController {
        var statusBarStyle: UIStatusBarStyle = .default

        // Alert controller's one deso not affect.
        override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }

        override func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = nil
        }
    }

    private var alertWindow: UIWindow?

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if let alertWindow = alertWindow {
            alertWindow.isHidden = true
            self.alertWindow = nil
        }
    }

    public func show(
        on window: UIWindow,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let windowScene = window.windowScene else { fatalError() }

        let alertWindow = UIWindow(windowScene: windowScene)
        self.alertWindow = alertWindow

        alertWindow.windowLevel = window.windowLevel + 1

        let rootVC = RootViewController()
        rootVC.statusBarStyle = windowScene.statusBarManager?.statusBarStyle ?? .default
        alertWindow.rootViewController = rootVC

        alertWindow.makeKeyAndVisible()

        rootVC.present(self, animated: animated, completion: completion)
    }
}

import ContentBlocker
import Database
import Foundation
import SwiftUI
import Utils

public typealias SettingsControllerDependency = UsesSettings & UsesContentFilterManager

public class SettingsController: UIHostingController<AnyView> {
    public init(dependency: SettingsControllerDependency) {
        weak var weakSelf: SettingsController?

        super.init(rootView: AnyView(
            RootView(
                settings: dependency.settings,
                contentFilterManager: dependency.contentFilterManager
            )
            .environment(\.nfl_dismiss) {
                weakSelf?.dismiss(animated: true)
            }
        ))

        weakSelf = self

        overrideUserInterfaceStyle = .dark
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

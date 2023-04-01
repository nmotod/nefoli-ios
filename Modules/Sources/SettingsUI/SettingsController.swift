import ContentBlocker
import Database
import Foundation
import SwiftUI

public typealias SettingsControllerDependency = UsesSettings & UsesContentFilterManager

public class SettingsController: UIHostingController<AnyView> {
    public init(dependency: SettingsControllerDependency) {
        super.init(rootView: AnyView(
            RootView(
                settings: dependency.settings,
                contentFilterManager: dependency.contentFilterManager
            )
        ))

        overrideUserInterfaceStyle = .dark
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

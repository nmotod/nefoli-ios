import Database
import Foundation
import SwiftUI

public typealias SettingsControllerDependency = UsesSettings

public class SettingsController: UIHostingController<SettingsController.RootView> {
    public struct RootView: View {
        @ObservedRealmObject public var settings: Settings

        public var body: some View {
            NavigationStack {
                RootSettingsList(
                    settings: settings
                )
            }
        }
    }

    public init(dependency: SettingsControllerDependency) {
        super.init(rootView: RootView(
            settings: dependency.settings
        ))

        overrideUserInterfaceStyle = .dark
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

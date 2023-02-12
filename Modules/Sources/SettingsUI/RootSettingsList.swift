import Database
import Foundation
import SwiftUI
import Theme

public struct RootSettingsList: View {
    @ObservedRealmObject public var settings: Settings

    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        List {
            Section {
                let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
                let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
                
                HStack {
                    Text("Version")
                    Spacer()
                    Text("\(shortVersion) (\(buildVersion))")
                }
            }
            .themedGroupedListContent()
        }
        .themedGroupedList()
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                }
                .themedTint()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct RootSettingssList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RootSettingsList(
                settings: PreviewUtilities.settings
            )
        }
    }
}

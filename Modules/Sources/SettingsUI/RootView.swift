import ContentBlocker
import Database
import Foundation
import SwiftUI
import Theme

public struct RootView: View {
    @ObservedRealmObject public var settings: Settings

    public var contentFilterManager: ContentFilterManager

    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            List {
                Section("Content Blocking (Ad Blocking)") {
                    NavigationLink(destination: {
                        ContentFilterList(contentFilterManager: contentFilterManager)
                    }, label: {
                        Text("Filters")
                    })
                }
                .themedGroupedListContent()

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "")
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
        }
        .preferredColorScheme(.dark)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(
            settings: PreviewUtilities.settings,
            contentFilterManager: PreviewUtilities.contentFilterManager
        )
    }
}
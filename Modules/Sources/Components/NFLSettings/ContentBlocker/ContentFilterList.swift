import NFLContentBlocker
import NFLDatabase
import NFLThemeSystem
import RealmSwift
import SwiftUI

struct ContentFilterList: View {
    let contentFilterManager: ContentFilterManager

    @MainActor
    private var filterSettings: RealmSwift.List<ContentFilterSetting> { contentFilterManager.filterSettings }

    @State private var isPresentedImportForm = false

    var body: some View {
        List {
            Section {
                if filterSettings.isEmpty {
                    Text("No Filters")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(filterSettings) { (setting: ContentFilterSetting) in
                        Row(filterSetting: setting)
                    }
                    .onDelete { indices in
                        try! filterSettings.realm!.write {
                            filterSettings.remove(atOffsets: indices)
                        }
                    }
                }
            }
            .themedGroupedListContent()

            Section {
                Button("Import Filters...", action: {
                    isPresentedImportForm = true
                })
            }
            .themedGroupedListContent()
        }
        .themedGroupedList()
        .navigationTitle("Content Filters")
        .toolbar {
            EditButton()
        }
        .sheet(isPresented: $isPresentedImportForm) {
            ContentFilterImportModal(contentFilterManager: contentFilterManager)
                .onDisappear {
                    isPresentedImportForm = false
                }
        }
    }
}

extension ContentFilterList {
    struct Row: View {
        @ObservedRealmObject var filterSetting: ContentFilterSetting

        var body: some View {
            Toggle(isOn: $filterSetting.isEnabled) {
                Text(filterSetting.name)
            }
        }
    }
}

struct ContentFiltering_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentFilterList(contentFilterManager: PreviewUtils.contentFilterManager)
        }
        .colorScheme(.dark)
    }
}

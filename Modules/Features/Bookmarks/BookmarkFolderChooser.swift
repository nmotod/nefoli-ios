import Database
import SwiftUI
import ThemeSystem

struct BookmarkFolderChooser: View {
    private struct FolderRow: Identifiable {
        var folder: BookmarkItem
        var depth: Int

        var id: BookmarkItem.ID { folder.id }
    }

    private let rows: [FolderRow]

    @State private var selectedFolder: BookmarkItem

    let bookmarkStore: BookmarkStore

    var onSelect: (BookmarkItem) -> Void

    init(
        selectedFolder: BookmarkItem,
        excludedFolderIDs: [BookmarkItem.ID],
        bookmarkStore: BookmarkStore,
        onSelect: @escaping (BookmarkItem) -> Void
    ) {
        self.selectedFolder = selectedFolder
        self.onSelect = onSelect
        self.bookmarkStore = bookmarkStore

        var rows = [FolderRow]()

        bookmarkStore.recursiveEnumerateAllFolders { folder, depth in
            if excludedFolderIDs.contains(folder.id) {
                return .ignore
            }

            rows.append(.init(
                folder: folder,
                depth: depth
            ))
            return .intoChildren
        }

        self.rows = rows
    }

    var body: some View {
        List(rows) { row in
            Button(action: {
                selectedFolder = row.folder

                onSelect(selectedFolder)
            }) {
                BookmarkListItem(
                    item: row.folder,
                    depth: row.depth,
                    checked: selectedFolder.id == row.folder.id
                )
            }
            .tint(Colors.tint.swiftUIColor)
            .listRowBackground(Colors.formFieldBackground.swiftUIColor)
        }
        .themedNavigationBar()
        .themedGroupedList()
        .navigationTitle("Choose Location")
    }
}

//
// struct BookmarkFolderChooser_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            let folder = Container.shared.bookmarkStore.bookmarksFolder
//            BookmarkFolderChooser(selectedFolder: folder, excludedFolderIDs: []) { _ in
//            }
//        }
//        .previewDevice("iPhone 12 mini")
//    }
// }

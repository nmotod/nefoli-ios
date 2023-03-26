import Database
import SwiftUI
import Theme

struct BookmarkFolderChooser: View {
    private struct FolderRow: Identifiable {
        var folder: BookmarkItem
        var depth: Int

        var id: BookmarkItem.ID { folder.id }
    }

    private let rows: [FolderRow]

    @State private var selectedFolder: BookmarkItem

    var onSelect: (BookmarkItem) -> Void

    let bookmarkManager: BookmarkManager

    init(
        bookmarkManager: BookmarkManager,
        selectedFolder: BookmarkItem,
        excludedFolderIDs: [BookmarkItem.ID],
        onSelect: @escaping (BookmarkItem) -> Void
    ) {
        self.selectedFolder = selectedFolder
        self.onSelect = onSelect
        self.bookmarkManager = bookmarkManager

        var rows = [FolderRow]()

        bookmarkManager.traverseAllFolders { folder, depth in
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
            .tint(Color(Colors.tint.color))
            .listRowBackground(Color(Colors.formFieldBackground.color))
        }
        .navigationTitle("Choose Location")
        .navigationBarTitleDisplayMode(.inline)
//            .introspectTableView { tableView in
//                tableView.backgroundColor = Colors.background.color
//            }
    }
}

//
// struct BookmarkFolderChooser_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            let folder = Container.shared.bookmarkManager.bookmarksFolder
//            BookmarkFolderChooser(selectedFolder: folder, excludedFolderIDs: []) { _ in
//            }
//        }
//        .previewDevice("iPhone 12 mini")
//    }
// }

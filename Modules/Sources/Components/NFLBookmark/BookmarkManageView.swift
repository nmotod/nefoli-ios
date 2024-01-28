import NFLDatabase
import SwiftUI
import Utils

protocol BookmarkManageViewDependency: UsesBookmarkStore {}

struct BookmarkManageView: View {
    let bookmarkStore: BookmarkStore

    var onOpen: (BookmarkItem) -> Void

    @Environment(\.nfl_dismiss) var dismiss

    @State private var presentedFolders: [BookmarkItem]

    init(
        bookmarkStore: BookmarkStore,
        initialFolder: BookmarkItem? = nil,
        onOpen: @escaping (BookmarkItem) -> Void
    ) {
        if let initialFolder {
            presentedFolders = sequence(first: initialFolder) { $0.parent }
                .filter { $0.id != .bookmarks }
                .reversed()
        } else {
            presentedFolders = []
        }

        self.bookmarkStore = bookmarkStore
        self.onOpen = onOpen
    }

    var body: some View {
        NavigationStack(path: $presentedFolders) {
            BookmarkList(
                folder: bookmarkStore.bookmarksFolder,
                bookmarkStore: bookmarkStore,
                onOpen: onOpen
            )
            .navigationDestination(for: BookmarkItem.self) { folder in
                BookmarkList(
                    folder: folder,
                    bookmarkStore: bookmarkStore,
                    onOpen: onOpen
                )
            }
        }
    }
}

#Preview("Bookmarks") {
    BookmarkManageView(
        bookmarkStore: PreviewUtils.bookmarkStore,
        onOpen: { _ in }
    )
    .environment(\.nfl_dismiss) {}
}

#Preview("Bookmarks deep") {
    BookmarkManageView(
        bookmarkStore: PreviewUtils.bookmarkStore,
        initialFolder: PreviewUtils.deepFolder,
        onOpen: { _ in }
    )
    .environment(\.nfl_dismiss) {}
}

#Preview("Bookmarks deepFavorites") {
    BookmarkManageView(
        bookmarkStore: PreviewUtils.bookmarkStore,
        initialFolder: PreviewUtils.deepFavoritesFolder,
        onOpen: { _ in }
    )
    .environment(\.nfl_dismiss) {}
}

#Preview("Bookmarks empty") {
    BookmarkManageView(
        bookmarkStore: PreviewUtils.emptyBookmarkStore,
        onOpen: { _ in }
    )
    .environment(\.nfl_dismiss) {}
}

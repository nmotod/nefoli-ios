import Database
import SwiftUI
import Utils

protocol BookmarkManageViewDependency: UsesBookmarkStore {}

struct BookmarkManageView: View {
    let bookmarkStore: BookmarkStore

    var onOpen: (BookmarkItem) -> Void

    @Environment(\.nfl_dismiss) var dismiss

    init(
        bookmarkStore: BookmarkStore,
        onOpen: @escaping (BookmarkItem) -> Void
    ) {
        self.bookmarkStore = bookmarkStore
        self.onOpen = onOpen
    }

    var body: some View {
        NavigationStack {
            BookmarkList(
                folder: bookmarkStore.favoritesFolder,
                bookmarkStore: bookmarkStore,
                onOpen: onOpen
            )
        }
    }
}

struct BookmarkManageView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkManageView(
            bookmarkStore: PreviewUtils.bookmarkStore,
            onOpen: { _ in }
        )
    }
}

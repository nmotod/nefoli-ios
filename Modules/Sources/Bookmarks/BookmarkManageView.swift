import Database
import SwiftUI
import Utils

struct BookmarkManageView: View {
    var bookmarkManager: BookmarkManager

    var onOpen: (BookmarkItem) -> Void

    @Environment(\.nfl_dismiss) var dismiss

    init(
        bookmarkManager: BookmarkManager,
        onOpen: @escaping (BookmarkItem) -> Void
    ) {
        self.bookmarkManager = bookmarkManager
        self.onOpen = onOpen
    }

    var body: some View {
        NavigationStack {
            BookmarkList(
                bookmarkManager: bookmarkManager,
                folder: bookmarkManager.favoritesFolder,
                onOpen: onOpen
            )
        }
    }
}

struct BookmarkManageView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkManageView(
            bookmarkManager: PreviewUtils.bookmarkManager,
            onOpen: { _ in }
        )
    }
}

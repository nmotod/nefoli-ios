import Database
import SwiftUI

public struct BookmarkManagerView: View {
    var bookmarkManager: BookmarkManager

    var onOpen: (BookmarkItem) -> Void

    init(
        bookmarkManager: BookmarkManager,
        onOpen: @escaping (BookmarkItem) -> Void
    ) {
        self.bookmarkManager = bookmarkManager
        self.onOpen = onOpen
    }

    public var body: some View {
        NavigationStack {
            BookmarkList(
                bookmarkManager: bookmarkManager,
                folder: bookmarkManager.favoritesFolder,
                onOpen: onOpen
            )
        }
    }
}

struct BookmarkManagerView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkManagerView(
            bookmarkManager: PreviewUtilities.bookmarkManager,
            onOpen: { _ in }
        )
    }
}

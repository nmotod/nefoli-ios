import Database
import SwiftUI
import UIKit

class EditBookmarkController: UIHostingController<NavigationView<BookmarkItemEditForm>> {
    init(bookmarkManager: BookmarkManager, editingItem: BookmarkItem, completion _: @escaping (_ isDone: Bool) -> Void) {
        super.init(rootView: NavigationView {
            BookmarkItemEditForm(
                editingItem: editingItem,
                bookmarkManager: bookmarkManager
            )
        })
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

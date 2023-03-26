import Database
import SwiftUI
import UIKit

public class BookmarkItemEditController: UIHostingController<NavigationView<BookmarkItemEditForm>> {
    public init(
        bookmarkManager: BookmarkManager,
        editingItem: BookmarkItem,
        completion _: @escaping (_ isDone: Bool) -> Void
    ) {
        super.init(rootView: NavigationView {
            BookmarkItemEditForm(
                bookmarkManager: bookmarkManager,
                editingItem: editingItem
            )
        })
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

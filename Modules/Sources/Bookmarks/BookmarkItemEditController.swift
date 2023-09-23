import Database
import SwiftUI
import UIKit

public class BookmarkItemEditController: UIHostingController<AnyView> {
    public init(
        editingItem: BookmarkItem,
        bookmarkStore: BookmarkStore,
        completion _: @escaping (_ isDone: Bool) -> Void
    ) {
        super.init(rootView: AnyView(
            NavigationView {
                BookmarkItemEditForm(
                    editingItem: editingItem,
                    bookmarkStore: bookmarkStore
                )
            }
        ))
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

import Database
import SwiftUI
import UIKit
import Utils

public class BookmarkEditController: UIHostingController<AnyView> {
    public init(
        editingItem: BookmarkItem,
        bookmarkStore: BookmarkStore,
        onDismiss: @escaping () -> Void
    ) {
        super.init(rootView: AnyView(
            NavigationView {
                BookmarkEditForm(
                    editingItem: editingItem,
                    bookmarkStore: bookmarkStore
                )
            }
            .environment(\.nfl_dismiss, onDismiss)
        ))
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

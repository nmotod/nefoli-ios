import NFLDatabase
import SwiftUI
import UIKit
import Utils

public class BookmarkManageController: UIHostingController<AnyView> {
    public init(
        bookmarkStore: BookmarkStore,
        onOpen: @escaping (BookmarkItem) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        super.init(rootView: AnyView(
            BookmarkManageView(
                bookmarkStore: bookmarkStore,
                onOpen: onOpen
            )
            .environment(\.nfl_dismiss, onDismiss)
        ))
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

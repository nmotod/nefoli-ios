import Database
import SwiftUI
import UIKit

public class BookmarkManageController: UIHostingController<AnyView> {
    public init(
        bookmarkManager: BookmarkManager,
        onOpen: @escaping (BookmarkItem) -> Void
    ) {
        super.init(rootView: AnyView(
            BookmarkManageView(
                bookmarkManager: bookmarkManager,
                onOpen: onOpen
            )
        ))
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

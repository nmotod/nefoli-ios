import Database
import SwiftUI
import UIKit

public class BookmarkManagerController: UIHostingController<BookmarkManagerView> {
    public init(
        bookmarkManager: BookmarkManager,
        onOpen: @escaping (BookmarkItem) -> Void
    ) {
        super.init(rootView: BookmarkManagerView(
            bookmarkManager: bookmarkManager,
            onOpen: onOpen
        ))
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

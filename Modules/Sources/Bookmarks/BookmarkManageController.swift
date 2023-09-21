import Database
import SwiftUI
import UIKit
import Utils

public class BookmarkManageController: UIHostingController<AnyView> {
    public init(
        bookmarkManager: BookmarkManager,
        onOpen: @escaping (BookmarkItem) -> Void
    ) {
        weak var weakSelf: BookmarkManageController?

        super.init(rootView: AnyView(
            BookmarkManageView(
                bookmarkManager: bookmarkManager,
                onOpen: onOpen
            )
            .environment(\.nfl_dismiss) {
                weakSelf?.dismiss(animated: true)
            }
        ))

        weakSelf = self
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

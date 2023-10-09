import Database
import Foundation
import SwiftUI
import UIKit

public class TabManageController: UIHostingController<AnyView> {
    public init(group: TabGroup) {
        super.init(rootView: AnyView(
            TabGroupManageView(group: group)
        ))
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

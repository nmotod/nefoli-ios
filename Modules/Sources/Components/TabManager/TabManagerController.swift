import Database
import UIKit

public typealias TabManagerControllerDependency = TabManagerRooViewControllerDependency

public class TabManagerController: UINavigationController {
    private let dependency: TabManagerControllerDependency

    public init(dependency: TabManagerControllerDependency) {
        self.dependency = dependency

        super.init(rootViewController: TabManagerRooViewController(dependency: dependency))

        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.medium()]
        isToolbarHidden = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

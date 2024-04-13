import Database
import SnapKit
import TabBrowserCore
import ThemeSystem
import UIKit

public typealias TabManagerRooViewControllerDependency = UsesTabStore & UsesScreenshotManager

class TabManagerRooViewController: UIViewController {
    let tabStore: TabStore

    private let dependency: TabManagerControllerDependency

    private var currentGroupView: TabGroupView!

    init(dependency: TabManagerControllerDependency) {
        self.dependency = dependency
        tabStore = dependency.tabStore

        super.init(nibName: nil, bundle: nil)

        title = "@count Tabs"

        toolbarItems = [
            UIBarButtonItem.flexibleSpace(),
            UIBarButtonItem(systemItem: .done, primaryAction: .init(handler: { _ in

            })),
        ]
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ThemeColors.background.color

        var style = TabGroupView.Style.expanded
        style.itemWidth = 120
        style.contentInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        style.isRounded = true
        style.interitemSpacing = 10
        style.screenshotScale = 1

        currentGroupView = .init(frame: view.bounds, style: style, dependency: dependency)
        currentGroupView.group = tabStore.groups.first

        view.addSubview(currentGroupView)

        currentGroupView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(200)
        }
    }
}

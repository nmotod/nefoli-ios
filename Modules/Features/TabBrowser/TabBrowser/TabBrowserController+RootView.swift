import Database
import Foundation
import ThemeSystem
import UIKit

private func makeBarBackgroundView() -> UIView {
    let view = UIView()
    view.backgroundColor = Colors.barBackground.color
    return view
}

extension TabBrowserController {
    class RootView: UIView {
        let topBarBackgroundView = makeBarBackgroundView()

        let bottomBarBackgroundView = makeBarBackgroundView()

        let omnibar = Omnibar()

        var addressBar: AddressBar { omnibar.addressBar }

        var progressBar: ProgressBar { omnibar.progressBar }

        let stickyToolbar = StickyContainerView(position: .bottom)

        let tabGroupView: TabGroupView

        let containerView = UIView()

        init(frame: CGRect, dependency: TabBrowserControllerDependency) {
            tabGroupView = .init(frame: .zero, style: .default, dependency: dependency)

            super.init(frame: frame)

            addSubview(topBarBackgroundView)
            topBarBackgroundView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(safeAreaLayoutGuide.snp.top)
            }

            stickyToolbar.contentView.addSubview(omnibar)
            omnibar.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            addSubview(bottomBarBackgroundView)
            addSubview(stickyToolbar)
            addSubview(tabGroupView)
            addSubview(containerView)

            tabGroupView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
            }

            stickyToolbar.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(tabGroupView.snp.top)
                make.height.equalTo(60)
            }

            bottomBarBackgroundView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(omnibar.snp.top)
            }

            containerView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(topBarBackgroundView.snp.bottom)
                make.bottom.equalTo(bottomBarBackgroundView.snp.top)
            }
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

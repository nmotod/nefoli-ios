import Database
import Foundation
import ThemeSystem
import UIKit

extension TabGroupController {
    class RootView: UIView {
        let bottomBarBackgroundView = UIVisualEffectView(effect: Effects.barBackground)

        let omnibar = Omnibar()

        var addressBar: AddressBar { omnibar.addressBar }

        var progressBar: ProgressBar { omnibar.progressBar }

        let stickyToolbar = StickyContainerView(position: .bottom)

        let tabGroupView: TabGroupView

        let containerView = UIView()

        init(frame: CGRect, dependency: TabGroupControllerDependency) {
            tabGroupView = .init(frame: .zero, style: .default, dependency: dependency)

            super.init(frame: frame)

            addSubview(containerView)
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            stickyToolbar.contentView.addSubview(omnibar)
            omnibar.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            addSubview(bottomBarBackgroundView)
            addSubview(stickyToolbar)
            addSubview(tabGroupView)

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
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
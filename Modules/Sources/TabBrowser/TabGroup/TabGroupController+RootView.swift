import Database
import Foundation
import Theme
import UIKit

extension TabGroupController {
    class RootView: UIView {
        let bottomBarBackgroundView = UIVisualEffectView(effect: Effects.barBackground)

        let toolbar: UIToolbar = {
            let appearance = UIToolbarAppearance()
            appearance.backgroundEffect = nil
            appearance.shadowColor = nil

            // A non-empty frame should be specified to prevent auto layout warning.
            let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: 300, height: 44))

            toolbar.standardAppearance = appearance
            toolbar.tintColor = Colors.tint.color

            return toolbar
        }()

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

            stickyToolbar.contentView.addSubview(toolbar)
            toolbar.snp.makeConstraints { make in
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
                make.height.equalTo(44)
            }

            bottomBarBackgroundView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(toolbar.snp.top)
            }
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

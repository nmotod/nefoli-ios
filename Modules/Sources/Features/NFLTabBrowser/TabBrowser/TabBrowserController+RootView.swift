import Foundation
import NFLDatabase
import NFLThemeSystem
import UIKit
import WebViewStickyInteraction

private func makeBarBackgroundView() -> UIView {
    let view = UIView()
    view.backgroundColor = ThemeColors.barBackground.color
    return view
}

extension TabBrowserController {
    class RootView: UIView {
        let topBarBackgroundView = makeBarBackgroundView()

        let bottomBarBackgroundView = makeBarBackgroundView()

        let stickyToolbar = ContainerStickyView(position: .bottom)

        let tabGroupView: TabGroupView

        let containerView = UIView()

        let preloadingView = UIView()

        init(frame: CGRect, dependency: TabBrowserControllerDependency) {
            tabGroupView = .init(frame: .zero, style: .default, dependency: dependency)

            super.init(frame: frame)

            preloadingView.isHidden = true
            addSubview(preloadingView)
            preloadingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            addSubview(containerView)
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            addSubview(topBarBackgroundView)
            topBarBackgroundView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(safeAreaLayoutGuide.snp.top)
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
                make.height.equalTo(Omnibar.defaultHeight)
            }

            bottomBarBackgroundView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(stickyToolbar.contentView.snp.top)
            }
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func setTabStickyBar(_ bar: UIView) {
            for v in stickyToolbar.contentView.subviews {
                v.removeFromSuperview()
            }

            stickyToolbar.contentView.addSubview(bar)
            bar.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}

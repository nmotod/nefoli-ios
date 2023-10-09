import Foundation
import ThemeSystem
import UIKit

extension TabViewController {
    class RootView: UIView {
        let topBarBackgroundView = UIVisualEffectView(effect: Effects.barBackground)

        override init(frame: CGRect) {
            super.init(frame: frame)

            addSubview(topBarBackgroundView)

            topBarBackgroundView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(safeAreaLayoutGuide.snp.top)
            }
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

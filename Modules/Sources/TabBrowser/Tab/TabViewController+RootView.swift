import Foundation
import Theme
import UIKit

extension TabViewController {
    class RootView: UIView {
        let addressBar = AddressBar()
        
        let stickyAddressBar = StickyContainerView(position: .top)

        let progressBar = ProgressBar()

        let topBarBackgroundView = UIVisualEffectView(effect: Effects.barBackground)

        override init(frame: CGRect) {
            super.init(frame: frame)

            addressBar.addSubview(progressBar)
            progressBar.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(0.5)
                make.height.equalTo(3)
            }
            
            stickyAddressBar.contentView.addSubview(addressBar)
            addressBar.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            addSubview(topBarBackgroundView)
            addSubview(stickyAddressBar)

            stickyAddressBar.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(safeAreaLayoutGuide.snp.top)
            }

            topBarBackgroundView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.right.bottom.equalTo(addressBar)
            }
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

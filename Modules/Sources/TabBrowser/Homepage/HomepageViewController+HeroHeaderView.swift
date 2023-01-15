import SwiftUI
import Theme
import UIKit

protocol HomepageHeroHeaderViewDelegate: AnyObject {
    func homeHeroHeaderRequestsEditAddress(_ heroHeaderView: HomepageViewController.HeroHeaderView)
}

private func clamp(min: CGFloat, max: CGFloat, percent: CGFloat) -> CGFloat {
    return min + (max - min) * percent
}

extension HomepageViewController {
    class HeroHeaderView: UICollectionReusableView {
        static let minimumHeight: CGFloat = 50
        static let maximumHeight: CGFloat = 200

        weak var delegate: HomepageHeroHeaderViewDelegate?

        private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))

        private let addressBar = AddressBar(frame: .init(x: 0, y: 0, width: 300, height: 60))

        private let addressBarBox = UIView()

        private var addressBarHeightConstraint: Constraint!

        private var addressBarAlignRightConstraint: Constraint!

        private var addressBarAlignLeftConstraint: Constraint!

        private let heroImageBox = UIView()

        private let topToolbar: UIToolbar = {
            let toolbar = UIToolbar()

            let appearance = UIToolbarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = nil
            appearance.backgroundColor = .clear
            appearance.shadowColor = .clear
            toolbar.standardAppearance = appearance

            return toolbar
        }()

        /// 0.0 <= percentExpansion <= 1.0
        /// - 0.0 : Sticky (top of hero header gets off screen)
        /// - 1.0 : Non-sticky (hero header is on screen)
        var percentExpansion: CGFloat = 0 {
            didSet {
                backgroundView.isHidden = (percentExpansion > 0)

                addressBarHeightConstraint.update(offset: clamp(min: 50, max: 60, percent: percentExpansion))
                addressBarAlignLeftConstraint.update(offset: clamp(min: 0, max: 10, percent: percentExpansion))
                addressBarAlignRightConstraint.update(offset: -clamp(min: 0, max: 10, percent: percentExpansion))

                let labelScale = clamp(min: 1.1, max: 1, percent: percentExpansion)
                addressBar.labelButton.titleLabel?.transform = .init(scaleX: labelScale, y: labelScale)

                heroImageBox.alpha = percentExpansion
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }

        private func setup() {
            addSubview(backgroundView)
            addSubview(addressBarBox)
            addressBarBox.addSubview(addressBar)
            addSubview(heroImageBox)
            addSubview(topToolbar)

            // Background  view
            backgroundView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            // Address bar
            addressBarBox.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(50)
            }

            addressBar.snp.makeConstraints { make in
                addressBarAlignLeftConstraint = make.left.equalToSuperview().constraint
                addressBarAlignRightConstraint = make.right.equalToSuperview().constraint
                make.centerY.equalToSuperview()
                addressBarHeightConstraint = make.height.equalTo(50).constraint
            }

            addressBar.labelButton.addTarget(self, action: #selector(editAddress(_:)), for: .touchUpInside)
            addressBar.labelButton.isPlaceholder = true
            addressBar.labelButton.addressText = NSLocalizedString("Search or enter address", comment: "")

            // Hero image
            heroImageBox.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.bottom.equalTo(addressBarBox.snp.top)
            }

            let heroImageView = UIImageView(image: Images.blade.image)
            heroImageBox.addSubview(heroImageView)
            heroImageView.contentMode = .scaleAspectFit
            heroImageView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(50)
                make.left.right.equalToSuperview().inset(20)
            }

//            topToolbar.items = [
//                UIBarButtonItem(systemItem: .flexibleSpace),
//                UIBarButtonItem(
//                    image: UIImage(systemName: "book"),
//                    landscapeImagePhone: nil,
//                    style: .plain,
//                    target: self,
//                    action: nil
//                ),
//                UIBarButtonItem(
//                    image: UIImage(systemName: "gearshape.fill"),
//                    landscapeImagePhone: nil,
//                    style: .plain,
//                    target: self,
//                    action: #selector(NFActionsResponder.nef_openSettings(_:))
//                ),
//            ]

            topToolbar.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview()
                make.height.equalTo(44)
            }

            percentExpansion = 0
        }

        @objc private func editAddress(_: Any) {
            delegate?.homeHeroHeaderRequestsEditAddress(self)
        }

        override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
            super.apply(layoutAttributes)

            guard let layoutAttributes = layoutAttributes as? LayoutAttributes else { return }

            percentExpansion = layoutAttributes.headerPercentExpansion
        }
    }
}

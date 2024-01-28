import NFLThemeSystem
import SwiftUI
import UIKit

protocol NewTabHeroHeaderViewDelegate: AnyObject {
    func newTabHeroHeaderRequestsEditAddress(_ heroHeaderView: NewTabViewController.HeroHeaderView)
}

private func clamp(min: CGFloat, max: CGFloat, percent: CGFloat) -> CGFloat {
    return min + (max - min) * percent
}

extension NewTabViewController {
    class HeroHeaderView: UICollectionReusableView {
        static let minimumHeight: CGFloat = 50
        static let maximumHeight: CGFloat = 200

        weak var delegate: NewTabHeroHeaderViewDelegate?

//        private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
        private let backgroundView: UIView = {
            let view = UIView()
            view.backgroundColor = ThemeColors.background.color
            return view
        }()

        private var addressBarHeightConstraint: Constraint!

        private var addressBarAlignRightConstraint: Constraint!

        private var addressBarAlignLeftConstraint: Constraint!

        private let heroImageBox = UIView()

        private let topToolbar: UIToolbar = {
            let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: 100, height: 44))

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
//                backgroundView.isHidden = (percentExpansion > 0)

                heroImageBox.alpha = percentExpansion
            }
        }

        var topToolbarItems: [UIBarButtonItem] {
            get {
                return topToolbar.items ?? []
            }

            set {
                topToolbar.items = newValue.map { item in
                    item.width = 70
                    item.tintColor = ThemeColors.tint.color.withAlphaComponent(0.5)
                    return item
                }
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
            addSubview(topToolbar)
            addSubview(heroImageBox)

            // Background view
            backgroundView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            topToolbar.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(44)
            }

            // Hero image
            heroImageBox.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.bottom.equalTo(topToolbar.snp.top)
            }

            let heroImageView = UIImageView(image: ThemeAssets.blade.image)
            heroImageBox.addSubview(heroImageView)
            heroImageView.contentMode = .scaleAspectFit
            heroImageView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(50)
                make.left.right.equalToSuperview().inset(20)
            }

            percentExpansion = 0
        }

        @objc private func editAddress(_: Any) {
            delegate?.newTabHeroHeaderRequestsEditAddress(self)
        }

        override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
            super.apply(layoutAttributes)

            guard let layoutAttributes = layoutAttributes as? LayoutAttributes else { return }

            percentExpansion = layoutAttributes.headerPercentExpansion
        }
    }
}

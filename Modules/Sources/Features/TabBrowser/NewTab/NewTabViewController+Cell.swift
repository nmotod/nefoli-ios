import Bookmark
import Database
import Foundation
import ThemeSystem
import UIKit
import Utils

public protocol NewTabViewControllerCellDependency: UsesBookmarkIconManager {}

extension NewTabViewController {
    class Cell: UICollectionViewCell {
        static let spacing: CGFloat = 8
        static let insets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        static let iconSize: CGFloat = 60
        static let iconCornerRadius: CGFloat = 12

        static let titleFont = UIFont.systemFont(ofSize: 13)

        static var preferredHeight: CGFloat {
            return iconSize + 10 + titleFont.lineHeight * 2 * 1.3
        }

        var bookmarkIconManager: BookmarkIconManager!

        let iconView = UIView()

        let iconImageView = UIImageView()

        let titleLabel = UILabel()

        var item: BookmarkItem? {
            didSet {
                itemDidSet()
            }
        }

        private var metadata: WebpageMetadata?

        override init(frame: CGRect) {
            super.init(frame: frame)

            iconView.backgroundColor = .white
            iconView.layer.cornerRadius = Self.iconCornerRadius
            iconView.layer.masksToBounds = true
            iconView.layer.shouldRasterize = true
            iconView.snp.makeConstraints { make in
                make.width.height.equalTo(Self.iconSize)
            }

            iconImageView.contentMode = .scaleAspectFill
            iconView.addSubview(iconImageView)
            iconImageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            titleLabel.font = Self.titleFont
            titleLabel.textColor = ThemeColors.textNormal.color
            titleLabel.numberOfLines = 2
            titleLabel.textAlignment = .center

            let vStack = UIStackView(arrangedSubviews: [iconView, titleLabel])
            vStack.axis = .vertical
            vStack.spacing = Self.spacing
            vStack.alignment = .center
            vStack.distribution = .fill
            vStack.directionalLayoutMargins = Self.insets

            contentView.addSubview(vStack)
            vStack.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.bottom.lessThanOrEqualToSuperview()
            }
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func injectIfNeeded(dependency: NewTabViewControllerCellDependency) {
            bookmarkIconManager = dependency.bookmarkIconManager
        }

        private func itemDidSet() {
            titleLabel.text = item?.title

            if let item = item {
                Task { @MainActor in
                    iconImageView.image = try! await bookmarkIconManager.getImage(for: item)
                }

            } else {
                iconImageView.image = nil
            }
        }

        override func prepareForReuse() {
            super.prepareForReuse()

            item = nil
            iconImageView.image = nil
        }

        var dragPreviewParameters: UIDragPreviewParameters {
            let parameters = UIDragPreviewParameters()

            parameters.visiblePath = UIBezierPath(
                roundedRect: iconView.frame,
                cornerRadius: Self.iconCornerRadius
            )

            return parameters
        }
    }
}

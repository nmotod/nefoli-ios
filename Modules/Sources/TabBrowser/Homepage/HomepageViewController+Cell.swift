import Database
import Foundation
import Theme
import UIKit

extension HomepageViewController {
    class Cell: UICollectionViewCell {
        static let spacing: CGFloat = 8
        static let insets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        static let imageSize: CGFloat = 60
        static let imageCornerRadius: CGFloat = 12

        static let titleFont = UIFont.systemFont(ofSize: 13)

        static var preferredHeight: CGFloat {
            return imageSize + 10 + titleFont.lineHeight * 2 * 1.3
        }

        let imageView = UIView()
        let titleLabel = UILabel()

        var item: BookmarkItem? {
            didSet {
                itemDidSet()
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            imageView.backgroundColor = .red
            imageView.layer.cornerRadius = Self.imageCornerRadius
            imageView.layer.masksToBounds = true
            imageView.layer.shouldRasterize = true
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(Self.imageSize)
            }

            titleLabel.font = Self.titleFont
            titleLabel.textColor = Colors.textNormal.color
            titleLabel.numberOfLines = 2
            titleLabel.textAlignment = .center

            let vStack = UIStackView(arrangedSubviews: [imageView, titleLabel])
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

        private func itemDidSet() {
            titleLabel.text = item?.title
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

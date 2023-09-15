import Foundation
import SnapKit
import Theme
import UIKit

class MenuSheetActionCell: UICollectionViewCell {
    private let button = UIButton()

    private let titleLable = UILabel()

    private let imageView = UIImageView()

    private var hStackView: UIStackView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        tintColor = Colors.tint.color

        var background = defaultBackgroundConfiguration()
        background.backgroundColor = Colors.background.color
        backgroundConfiguration = background

        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.edges.equalToSuperview()
        }

        hStackView = UIStackView(arrangedSubviews: [imageView, titleLable])
        hStackView.isUserInteractionEnabled = false
        hStackView.axis = .horizontal
        hStackView.distribution = .fill
        hStackView.alignment = .center
        hStackView.spacing = 16
        button.addSubview(hStackView)
        hStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(
                top: 0, left: 16, bottom: 0, right: 16
            ))
        }

        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .light)
        imageView.contentMode = .center
        imageView.snp.makeConstraints { make in
            make.width.equalTo(29)
            make.height.equalTo(29)
        }

        titleLable.textColor = tintColor
        titleLable.font = .systemFont(ofSize: 15)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var action: UIAction? {
        didSet {
            button.removeTarget(nil, action: nil, for: .allEvents)

            imageView.image = action?.image
            titleLable.text = action?.title

            if let action {
                button.addAction(action, for: .touchUpInside)
            }
        }
    }
}

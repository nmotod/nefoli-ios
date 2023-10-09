import Combine
import Foundation
import SnapKit
import Theme
import UIKit

class MenuSheetActionCell: UICollectionViewListCell {
    private let button = UIButton()

    private var buttonStateSubscription: AnyCancellable?

    override init(frame: CGRect) {
        super.init(frame: frame)

        var background = defaultBackgroundConfiguration()
        background.backgroundColor = Colors.background.color
        backgroundConfiguration = background

        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        buttonStateSubscription = Publishers.Merge(
            button.publisher(for: \.isHighlighted),
            button.publisher(for: \.isSelected)
        )
        .sink { [weak self] _ in
            self?.didUpdateButtonState()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(action: UIAction?, afterAction: UIAction?) {
        button.removeTarget(nil, action: nil, for: .allEvents)

        var content = defaultContentConfiguration()

        content.text = action?.title
        content.textProperties.font = .systemFont(ofSize: 15)
        content.textProperties.color = Colors.textNormal.color

        content.image = action?.image
        content.imageProperties.preferredSymbolConfiguration = .init(
            pointSize: 18,
            weight: .regular
        )
        content.imageProperties.tintColor = Colors.tint.color

        // The contentView will put at the frontmost
        contentConfiguration = content
        bringSubviewToFront(button)

        if let action {
            button.addAction(action, for: .touchUpInside)
        }

        if let afterAction {
            button.addAction(afterAction, for: .touchUpInside)
        }
    }

    private func didUpdateButtonState() {
        if button.isHighlighted || button.isSelected {
            button.backgroundColor = .init(white: 1, alpha: 0.05)

        } else {
            UIView.animate(withDuration: 0.2) {
                self.button.backgroundColor = nil
            }
        }
    }
}

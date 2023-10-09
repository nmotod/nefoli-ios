import Foundation
import ThemeSystem
import UIKit

class MenuSheetHeaderView: UIStackView {
    let titleLabel: UILabel

    let urlLabel: UILabel

    var onClose: (() -> Void)?

    init() {
        titleLabel = .init()
        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.textColor = Colors.textNormal.color

        urlLabel = .init()
        urlLabel.font = .systemFont(ofSize: 14)
        urlLabel.textColor = Colors.textNormal.color.withAlphaComponent(0.6)

        super.init(frame: .zero)

        axis = .vertical
        distribution = .fill

        addArrangedSubview({
            let hStack = UIStackView()

            hStack.axis = .horizontal
            hStack.distribution = .fill

            // Labels
            hStack.addArrangedSubview({
                let vStack = UIStackView(arrangedSubviews: [titleLabel, urlLabel])
                vStack.axis = .vertical
                vStack.alignment = .leading

                vStack.directionalLayoutMargins = .init(top: 10, leading: 20, bottom: 10, trailing: 10)
                vStack.isLayoutMarginsRelativeArrangement = true

                vStack.snp.makeConstraints { make in
                    make.height.greaterThanOrEqualTo(60)
                }

                return vStack
            }())

            // Close button
            hStack.addArrangedSubview({
                let closeButton = UIButton(primaryAction: .init(
                    image: UIImage(
                        systemName: "xmark",
                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 14)
                    ),
                    handler: { [weak self] _ in
                        self?.onClose?()
                    }
                ))
                closeButton.tintColor = Colors.tint.color.withAlphaComponent(0.4)
                closeButton.snp.makeConstraints { make in
                    make.width.equalTo(44)
                }
                return closeButton
            }())

            return hStack
        }())

        // Divider
        addArrangedSubview({
            let divider = UIView()
            divider.backgroundColor = .init(white: 1, alpha: 0.1)
            divider.snp.makeConstraints { make in
                make.height.equalTo(1)
            }
            return divider
        }())
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

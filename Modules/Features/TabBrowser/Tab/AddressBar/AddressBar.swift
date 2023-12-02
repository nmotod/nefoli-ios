import Foundation
import ThemeSystem
import UIKit

class AddressBar: UIView {
    struct ContentConfiguration {
        var url: URL?
        var isSecure: Bool = false

        var hasInternalURL: Bool {
            guard let url else { return false }
            return InternalURL.isInternalURL(url)
        }
    }

    static let borderCornerRadius: CGFloat = 12

    var contentConfiguration: ContentConfiguration? {
        didSet {
            updateContent()
        }
    }

    let addressButton: AddressButton

    let reloadButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.buttonSize = .small
        config.image = UIImage(systemName: "arrow.clockwise")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 13)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.tintColor = ThemeColors.tint.color
        return button
    }()

    init(
        frame: CGRect,
        borderInsets: UIEdgeInsets
    ) {
        addressButton = AddressButton(frame: frame, borderInsets: borderInsets)

        super.init(frame: frame)

        addSubview(addressButton)
        addressButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(reloadButton)
        reloadButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(44)
        }

        updateContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateContent() {
        addressButton.contentConfiguration = contentConfiguration

        if let contentConfiguration, !contentConfiguration.hasInternalURL {
            reloadButton.isHidden = false
        } else {
            reloadButton.isHidden = true
        }
    }

    class AddressButton: UIButton {
        let borderInsets: UIEdgeInsets

        override var isHighlighted: Bool {
            didSet {
                borderLayer.backgroundColor = isHighlighted
                    ? ThemeColors.addressBarLabelBackgroundHighlighted.color.cgColor
                    : ThemeColors.addressBarLabelBackgroundNormal.color.cgColor
            }
        }

        var contentConfiguration: ContentConfiguration? {
            didSet {
                guard let contentConfiguration,
                      !contentConfiguration.hasInternalURL
                else {
                    contentView.isHidden = true
                    placeholderLabel.isHidden = false
                    return
                }

                contentView.isHidden = false
                placeholderLabel.isHidden = true

                label.text = contentConfiguration.url?.host
                secureIconView.isHidden = !contentConfiguration.isSecure
            }
        }

        private let borderLayer: CALayer = {
            let layer = CALayer()
            layer.backgroundColor = ThemeColors.addressBarLabelBackgroundNormal.color.cgColor
            layer.cornerRadius = borderCornerRadius
            layer.masksToBounds = true
            return layer
        }()

        private let label: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14)
            label.textColor = ThemeColors.label.color
            label.textAlignment = .center
            label.lineBreakMode = .byTruncatingMiddle
            return label
        }()

        private let secureIconView: UIImageView = {
            let secureIconView = UIImageView(image: UIImage(systemName: "lock.fill"))
            secureIconView.preferredSymbolConfiguration = .init(pointSize: 10)
            secureIconView.tintColor = ThemeColors.addressBarLabelTextNormal.color
            secureIconView.contentMode = .center
            return secureIconView
        }()

        private lazy var contentView: UIStackView = {
            let contentView = UIStackView(arrangedSubviews: [secureIconView, label])
            contentView.isUserInteractionEnabled = false
            contentView.spacing = 5
            return contentView
        }()

        private let placeholderLabel: UILabel = {
            let label = UILabel()
            label.isUserInteractionEnabled = false
            label.font = .systemFont(ofSize: 14)
            label.textColor = ThemeColors.addressBarLabelPlaceholder.color
            label.text = String(localized: "Search or enter address")
            label.isHidden = true
            return label
        }()

        init(frame: CGRect, borderInsets: UIEdgeInsets) {
            self.borderInsets = borderInsets

            super.init(frame: frame)

            layer.addSublayer(borderLayer)

            addSubview(placeholderLabel)
            placeholderLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
            }

            addSubview(contentView)
            contentView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.lessThanOrEqualToSuperview().inset(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 55))
            }
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSublayers(of layer: CALayer) {
            super.layoutSublayers(of: layer)

            borderLayer.frame = bounds.inset(by: borderInsets)
        }
    }
}

import Theme
import UIKit

class AddressBarLabelButton: UIButton {
    private let borderLayer = AddressBackgroundLayer()

    var addressText = "" {
        didSet {
            label.text = addressText
        }
    }

    var isSecure = false {
        didSet {
            secureIconView.isHidden = !isSecure
        }
    }

    var isPlaceholder = false {
        didSet {
            if isPlaceholder {
                label.textColor = Colors.addressBarLabelPlaceholder.color
            } else {
                label.textColor = Colors.addressBarLabelTextNormal.color
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            borderLayer.isHighlighted = isHighlighted
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        postInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        postInit()
    }

    private var borderBox: UIView!

    private var labelBox: UIStackView!

    private var secureIconView: UIImageView!

    private var label: UILabel!

    private func postInit() {
        autoresizesSubviews = false

        layer.addSublayer(borderLayer)

        borderBox = UIView()
        borderBox.isUserInteractionEnabled = false
        addSubview(borderBox)

        secureIconView = UIImageView(image: UIImage(
            systemName: "lock.fill",
            withConfiguration: UIImage.SymbolConfiguration(scale: .small)
        ))
        secureIconView.transform = .init(translationX: 0, y: 1)

        label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)

        labelBox = UIStackView(arrangedSubviews: [secureIconView, label])
        labelBox.axis = .horizontal
        labelBox.spacing = 5
        borderBox.addSubview(labelBox)
        labelBox.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        isPlaceholder = false
        isSecure = false

        assert(![borderBox, labelBox, secureIconView, labelBox].contains(nil))
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        borderLayer.frame = bounds
        borderBox.frame = borderLayer.textRectFor(bounds: bounds)

        CATransaction.commit()
    }
}

import Theme
import UIKit

private let clearButtonWidth: CGFloat = 30

class AddressTextField: UITextField {
    private let borderLayer = AddressBackgroundLayer()

    /// Custom clear button.
    /// Use to change button color.
    private lazy var clearButton: UIButton! = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(clearText(_:)), for: .touchUpInside)

        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = Colors.addressBarLabelPlaceholder.color
        button.alpha = 0.5
        button.contentHorizontalAlignment = .left

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        postInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        postInit()
    }

    private func postInit() {
        font = UIFont.systemFont(ofSize: 15)
        textColor = Colors.addressBarLabelTextNormal.color

        returnKeyType = .go
        enablesReturnKeyAutomatically = true

        // Border & background
        borderStyle = .none
        backgroundColor = nil
        layer.addSublayer(borderLayer)

        // Use custom clear button.
        clearButtonMode = .never
        rightView = clearButton
        rightViewMode = .whileEditing

        // .center not work with custom textRect.
        contentVerticalAlignment = .top

        placeholder = NSLocalizedString("Search or enter address", comment: "")
    }

    @objc private func clearText(_: Any) {
        text = nil
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        borderLayer.frame = bounds

        CATransaction.commit()
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        guard let lineHeight = font?.lineHeight else {
            return bounds
        }

        let borderRect = borderLayer.borderLayerRectFor(bounds: bounds)

        if borderRect.width <= borderRect.height {
            return borderRect
        }

        var rect = borderRect.insetBy(dx: borderRect.height / 2, dy: 0)
        rect.origin.y += (rect.height - lineHeight) / 2
        rect.size.width += -clearButtonWidth + borderRect.height / 2

        return rect
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let borderRect = borderLayer.borderLayerRectFor(bounds: bounds)

        let rect = CGRect(
            x: borderRect.maxX - clearButtonWidth,
            y: borderRect.minY,
            width: clearButtonWidth,
            height: borderRect.height
        )
        return rect
    }

    /// Draws placeholder with custom text color
    /// Because attributedPlaceholder cannot change text color.
    override func drawPlaceholder(in rect: CGRect) {
        guard let placeholder = placeholder,
              !placeholder.isEmpty,
              let font = font else { return }

        let str = NSAttributedString(string: placeholder, attributes: [
            .foregroundColor: Colors.addressBarLabelPlaceholder.color,
            .font: font,
        ])
        str.draw(in: rect)
    }
}

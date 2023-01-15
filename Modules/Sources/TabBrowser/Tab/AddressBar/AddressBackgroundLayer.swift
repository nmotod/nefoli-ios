import Theme
import UIKit

class AddressBackgroundLayer: CALayer {
    static let borderInsets = UIEdgeInsets(top: 4, left: 10, bottom: 10, right: 10)

    private(set) lazy var borderLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = Colors.addressBarLabelBackgroundNormal.color.cgColor
        layer.masksToBounds = true
        return layer
    }()

    var isHighlighted: Bool = false {
        didSet {
            borderLayer.backgroundColor = isHighlighted
                ? Colors.addressBarLabelBackgroundHighlighted.color.cgColor
                : Colors.addressBarLabelBackgroundNormal.color.cgColor
        }
    }

    override init() {
        super.init()
        postInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        postInit()
    }

    private func postInit() {
        shouldRasterize = true

        addSublayer(borderLayer)
    }

    override func layoutSublayers() {
        super.layoutSublayers()

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        borderLayer.frame = borderLayerRectFor(bounds: bounds)
        borderLayer.cornerRadius = borderLayer.frame.height / 2

        CATransaction.commit()
    }

    func borderLayerRectFor(bounds: CGRect) -> CGRect {
        let rect = bounds.inset(by: type(of: self).borderInsets)
        return rect
    }

    func textRectFor(bounds: CGRect) -> CGRect {
        let borderRect = borderLayerRectFor(bounds: bounds)

        if borderRect.width <= borderRect.height {
            return borderRect
        }

        let rect = borderRect.insetBy(dx: borderRect.height / 2, dy: 0)
        return rect
    }
}

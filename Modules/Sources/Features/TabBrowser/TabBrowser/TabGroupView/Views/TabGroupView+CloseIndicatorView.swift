import SnapKit
import UIKit

extension TabGroupView {
    class CloseIndicatorView: UIView {
        enum State {
            case hidden
            case recognizing
            case recognized
        }

        var state: State = .hidden {
            didSet {
                stateDidChange()
            }
        }

        var style: Style {
            didSet {
                styleDidChange()
            }
        }

        private let fillColor = UIColor.systemRed

        private let shapeLayer = CAShapeLayer()

        private var widthConstraint: Constraint!

        private var heightConstraint: Constraint!

        init(frame: CGRect, style: Style) {
            self.style = style

            super.init(frame: frame)

            isUserInteractionEnabled = false

            snp.makeConstraints { make in
                widthConstraint = make.width.equalTo(80).constraint
                heightConstraint = make.height.equalTo(50).constraint
            }

            shapeLayer.fillColor = fillColor.cgColor
            layer.addSublayer(shapeLayer)

            stateDidChange()
            styleDidChange()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func stateDidChange() {
            switch state {
            case .hidden:
                isHidden = true

            case .recognizing:
                isHidden = false
                alpha = 0.3

            case .recognized:
                isHidden = false
                alpha = 1
            }
        }

        private func styleDidChange() {
            widthConstraint.update(offset: style.itemWidth)

            setNeedsLayout()
        }

        override func layoutSublayers(of _: CALayer) {
            super.layoutSublayers(of: layer)

            CATransaction.begin()
            CATransaction.setDisableActions(true)

            let triangleHeight = 15 as CGFloat
            let triangleY0 = bounds.height - triangleHeight
            let triangleY1 = bounds.height - 1

            let path = UIBezierPath(rect: .init(
                x: 0,
                y: 0,
                width: bounds.width,
                height: triangleY0
            ))
            path.move(to: .init(x: 0, y: triangleY0))
            path.addLine(to: .init(x: bounds.width, y: triangleY0))
            path.addLine(to: .init(x: bounds.width / 2, y: triangleY1))
            path.close()

            shapeLayer.frame = layer.bounds
            shapeLayer.path = path.cgPath

            CATransaction.commit()
        }
    }
}

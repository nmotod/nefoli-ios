import Foundation
import SnapKit
import UIKit

public class ContainerStickyView: UIView, StickyViewProtocol {
    public enum Position {
        case top
        case bottom
    }

    public let position: Position

    public let contentView = UIView()

    public var maxHeight: CGFloat { frame.height }

    public var minHeight: CGFloat = 0

    public var currentPercentHidden: CGFloat = 0 {
        didSet {
            switch position {
            case .top:
                hiddenOffsetConstraint.update(offset: -currentHiddenHeight)

            case .bottom:
                hiddenOffsetConstraint.update(offset: currentHiddenHeight)
            }

            contentView.alpha = 1 - currentPercentHidden
            isUserInteractionEnabled = currentPercentHidden < 1
        }
    }

    public var currentHiddenHeight: CGFloat {
        return minHeight + (maxHeight - minHeight) * currentPercentHidden
    }

    private var hiddenOffsetConstraint: Constraint!

    public init(position: Position) {
        self.position = position

        super.init(frame: .zero)

        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalToSuperview()

            switch position {
            case .top:
                hiddenOffsetConstraint = make.top.equalToSuperview().constraint

            case .bottom:
                hiddenOffsetConstraint = make.bottom.equalToSuperview().constraint
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

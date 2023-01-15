import Foundation
import UIKit

class StickyContainerView: UIView, StickyView {
    enum Position {
        case top
        case bottom
    }

    let position: Position

    let contentView = UIView()

    var maximumHeight: CGFloat { frame.height }
    
    var minimumHeight: CGFloat = 0
    
    var percentHidden: CGFloat = 0 {
        didSet {
            switch position {
            case .top:
                hiddenOffsetConstraint.update(offset: -hiddenHeight)

            case .bottom:
                hiddenOffsetConstraint.update(offset: hiddenHeight)
            }

            contentView.alpha = 1 - percentHidden
            isUserInteractionEnabled = percentHidden < 1
        }
    }
    
    var hiddenHeight: CGFloat {
        return minimumHeight + (maximumHeight - minimumHeight) * percentHidden
    }

    private var hiddenOffsetConstraint: Constraint!

    init(position: Position) {
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
    
    func layoutSuperviewIfNeeded() {
        superview?.layoutIfNeeded()
    }
}

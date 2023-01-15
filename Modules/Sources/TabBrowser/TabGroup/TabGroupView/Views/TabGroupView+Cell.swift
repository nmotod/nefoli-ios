import Database
import UIKit

protocol TabGroupViewCellDelegate: AnyObject {
    func tabGroupViewCell(_ cell: TabGroupView.Cell, dragStateDidChange dragState: UICollectionViewCell.DragState)

    func tabGroupViewCellRequestsDelete(_ cell: TabGroupView.Cell)
}

public typealias TabGroupViewCellDependency = UsesScreenshotManager

extension TabGroupView {
    class Cell: UICollectionViewCell {
        private var dependency: TabGroupViewCellDependency!
        
        weak var delegate: TabGroupViewCellDelegate?
        
        var tab: Tab? {
            didSet {
                if let oldValue = oldValue, !oldValue.isInvalidated {
                    if tab?.id == oldValue.id {
                        return
                    }
                }
                
                didChangeTab()
            }
        }
        
        var isActive: Bool = false {
            didSet {
                didChangeState()
            }
        }
        
        private let tabContentView = UIView()
        
        private lazy var screenshotView = ScreenshotView(frame: .zero, dependency: dependency)
        
        private let activeIndicator = ActiveIndicatorView()
        
        private var hiddenActiveIndicatorConstraint: Constraint!
        
        private var style: Style = .default
        
        func setup(delegate: TabGroupViewCellDelegate?, tab: Tab?, isActive: Bool) {
            self.delegate = delegate
            self.tab = tab
            self.isActive = isActive
        }
        
        public func injectIfNeeded(dependency: TabGroupViewCellDependency) {
            if self.dependency != nil {
                return
            }
            
            self.dependency = dependency
            
            contentView.addSubview(tabContentView)
            tabContentView.addSubview(screenshotView)
            tabContentView.addSubview(activeIndicator)
            
            tabContentView.layer.shouldRasterize = true
            tabContentView.layer.rasterizationScale = UIScreen.main.scale
            tabContentView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            activeIndicator.snp.makeConstraints { make in
                //            guard let superview = activeIndicator.superview else { return }
                
                make.left.right.top.equalToSuperview()
                make.height.equalTo(30).priority(.low)
                
                //            make.bottom.equalToSuperview().priority(.low)
                //            make.top.equalToSuperview().priority(.low)
                
                hiddenActiveIndicatorConstraint = make.height.equalTo(0).constraint
                hiddenActiveIndicatorConstraint.deactivate()
                
                //            hiddenActiveIndicatorConstraint = make.bottom.equalTo(superview.snp.top).constraint
                //            hiddenActiveIndicatorConstraint = make.top.equalTo(superview.snp.bottom).constraint
                //            hiddenActiveIndicatorConstraint.deactivate()
            }
            
            screenshotView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(activeIndicator.snp.bottom)
            }
        }
        
        override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
            super.apply(layoutAttributes)
            
            if dependency == nil {
                return
            }
            
            guard let layoutAttributes = layoutAttributes as? LayoutAttributes else {
                // Possibility that layoutAttributes is nil.
                return
            }
            
            let style = layoutAttributes.style
            self.style = style
            
            activeIndicator.alpha = style.hidesActiveIndicator ? 0 : 1
            
            screenshotView.scale = style.screenshotScale
            
            if style.isRounded {
                screenshotView.layer.cornerRadius = 10
                screenshotView.layer.masksToBounds = true
            }
            
            if style.showsDropShadow {
                tabContentView.layer.shadowRadius = 5
                tabContentView.layer.shadowColor = UIColor.black.cgColor
                tabContentView.layer.shadowOpacity = 0.3
                tabContentView.layer.shadowOffset = .init(width: 0, height: 5)
            }
        }
        
        func didChangeTab() {
            screenshotView.source = tab
        }
        
        func didChangeState() {
            //        titleBox.backgroundColor = isActive
            //            ? Colors.tabGroupViewTitleBackgroundActive.color
            //            : Colors.tabGroupViewTitleBackgroundNormal.color
            
            if style.hidesActiveIndicator {
                setActiveIndicatorHidden(true)
            } else {
                setActiveIndicatorHidden(!isActive)
            }
        }
        
        func setActiveIndicatorHidden(_ isHidden: Bool) {
            hiddenActiveIndicatorConstraint.isActive = isHidden
        }
        
        func dragPreviewParameters() -> UIDragPreviewParameters? {
            if !style.isRounded {
                return nil
            }
            
            let params = UIDragPreviewParameters()
            return params
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            
            isHidden = false
            tab = nil
            isActive = false
            
            previousDragState = .none
        }
        
        // MARK: - Drag
        
        private var previousDragState: DragState = .none
        
        override func dragStateDidChange(_ dragState: UICollectionViewCell.DragState) {
            super.dragStateDidChange(dragState)
            
            previousDragState = dragState
            
            delegate?.tabGroupViewCell(self, dragStateDidChange: dragState)
        }
    }
}

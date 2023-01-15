import UIKit

extension TabGroupView {
    class HeaderView: UICollectionReusableView {
        private let menuButton = UIButton(type: .custom)
        
        var onMenuHandler: ((HeaderView) -> Void)?
        
        var count: Int = 0 {
            didSet {
                update()
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
        
        private func postInit() {
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .thin)
            menuButton.setImage(UIImage(systemName: "ellipsis.circle", withConfiguration: config), for: .normal)
            
            //        addSubview(menuButton)
            //        menuButton.snp.makeConstraints { (make) in
            //            make.edges.equalTo(safeAreaLayoutGuide)
            //        }
            
            menuButton.addTarget(self, action: #selector(menuButtonDidClick), for: .touchUpInside)
        }
        
        @objc private func menuButtonDidClick() {
            onMenuHandler?(self)
        }
        
        func update() {
            //        countButton.setTitle("\(count)", for: .normal)
        }
    }
}

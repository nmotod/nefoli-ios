import UIKit

extension TabGroupView {
    class FooterView: UICollectionReusableView {
        private let addButton = UIButton(type: .custom)
        
        var onAddHandler: ((FooterView) -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }
        
        private func setup() {
            addButton.setImage(UIImage(systemName: "plus"), for: .normal)
            
            addSubview(addButton)
            addButton.snp.makeConstraints { make in
                make.edges.equalTo(safeAreaLayoutGuide)
            }
            
            addButton.addTarget(self, action: #selector(addButtonDidClick), for: .touchUpInside)
        }
        
        @objc private func addButtonDidClick() {
            onAddHandler?(self)
        }
    }
}

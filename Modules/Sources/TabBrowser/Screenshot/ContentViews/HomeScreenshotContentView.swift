import UIKit

class HomeScreenshotContentView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.89, alpha: 1)

        let iconView = UIImageView(image: UIImage(systemName: "square.grid.3x3.fill")!)
        addSubview(iconView)

        iconView.tintColor = .white

        iconView.snp.makeConstraints { make in
            make.width.equalTo(35)
            make.height.equalTo(34)
            make.center.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

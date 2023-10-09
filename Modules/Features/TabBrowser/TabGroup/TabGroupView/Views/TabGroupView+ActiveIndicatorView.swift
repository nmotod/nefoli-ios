import Foundation
import ThemeSystem
import UIKit

private let arrowImage: UIImage? = {
    let config = UIImage.SymbolConfiguration(weight: .thin)
    return UIImage(systemName: "chevron.compact.up", withConfiguration: config)
}()

extension TabGroupView {
    class ActiveIndicatorView: UIView {
        private let arrow = UIImageView(image: arrowImage)

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }

        private func setup() {
            backgroundColor = Colors.tabCollectionActiveIndicatorTint.color
            clipsToBounds = true

            addSubview(arrow)
            arrow.contentMode = .scaleAspectFit
            arrow.tintColor = UIColor(white: 1, alpha: 0.8)
            arrow.snp.makeConstraints { make in
                make.width.equalTo(30)
                make.height.equalTo(30)
                make.center.equalToSuperview()
            }
        }
    }
}

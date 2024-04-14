import ThemeSystem
import UIKit

extension Omnibar {
    public static func makeOmnibarButton(primaryAction: UIAction) -> UIButton {
        primaryAction.title = ""

        let button = UIButton(primaryAction: primaryAction)
        button.tintColor = ThemeColors.tint.color
        button.snp.makeConstraints { make in
            make.width.equalTo(44)
        }

        return button
    }
}

import ThemeSystem
import UIKit

extension Omnibar {
    public static func makeOmnibarButton(primaryAction: UIAction) -> UIButton {
        primaryAction.title = ""

        let button = UIButton(primaryAction: primaryAction)
        configureOmnibarButton(button: button)

        return button
    }

    public static func configureOmnibarButton(button: UIButton) {
        button.tintColor = ThemeColors.tint.color
        button.snp.makeConstraints { make in
            make.width.equalTo(44)
        }
    }
}

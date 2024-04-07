import Foundation
import ThemeSystem
import UIKit

extension AddressBar {
    static func makeAccessoryButton(primaryAction: UIAction) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.buttonSize = .small
        config.preferredSymbolConfigurationForImage = .init(pointSize: 13)

        let button = UIButton(configuration: config, primaryAction: primaryAction)
        button.tintColor = ThemeColors.tint.color
        return button
    }
}

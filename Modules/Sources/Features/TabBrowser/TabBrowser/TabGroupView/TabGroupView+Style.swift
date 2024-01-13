import UIKit

extension TabGroupView {
    struct Style: Equatable {
        var height: CGFloat = 90
        var itemWidth: CGFloat = 70
        var headerWidth: CGFloat = 0
        var interitemSpacing: CGFloat = 2
        var contentInset: UIEdgeInsets = .init(top: 0, left: 30, bottom: 0, right: 0)
        var indentationWidthPerDepth: CGFloat = 3
        var screenshotScale: CGFloat = 1.5
        var isRounded: Bool = false
        var showsDropShadow: Bool = false
        var showsTitle: Bool = false
        var showsActiveIndicator: Bool = true

        var hidesActiveIndicator: Bool { !showsActiveIndicator }

        static var `default`: Style { .collapsed }

        static var collapsed = Style()

        // TODO: var --> let
        static var expanded = Style(
            indentationWidthPerDepth: 10,
            screenshotScale: 2,
            showsTitle: true,
            showsActiveIndicator: false
        )

        static var list = Style(
            indentationWidthPerDepth: 10,
            screenshotScale: 2,
            showsTitle: true,
            showsActiveIndicator: false
        )
    }
}

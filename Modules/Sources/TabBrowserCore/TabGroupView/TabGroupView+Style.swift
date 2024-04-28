import UIKit

extension TabGroupView {
    public struct Style: Equatable {
        public var height: CGFloat = 90
        public var itemWidth: CGFloat = 70
        public var headerWidth: CGFloat = 0
        public var interitemSpacing: CGFloat = 2
        public var contentInset: UIEdgeInsets = .init(top: 0, left: 30, bottom: 0, right: 0)
        public var indentationWidthPerDepth: CGFloat = 3
        public var screenshotScale: CGFloat = 1.5
        public var isRounded: Bool = false
        public var showsDropShadow: Bool = false
        public var showsTitle: Bool = false
        public var showsActiveIndicator: Bool = true

        public var hidesActiveIndicator: Bool { !showsActiveIndicator }

        public static var `default`: Style { .collapsed }

        public static var collapsed = Style()

        public static let expanded = Style(
            indentationWidthPerDepth: 10,
            screenshotScale: 2,
            showsTitle: true,
            showsActiveIndicator: false
        )

        public static let list = Style(
            indentationWidthPerDepth: 10,
            screenshotScale: 2,
            showsTitle: true,
            showsActiveIndicator: false
        )
    }
}

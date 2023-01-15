import UIKit

extension TabGroupView {
    class LayoutAttributes: UICollectionViewLayoutAttributes {
        var style: Style = .collapsed

        override func copy(with zone: NSZone? = nil) -> Any {
            let object = super.copy(with: zone) as! LayoutAttributes

            object.style = style

            return object
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard type(of: object) == type(of: self),
                  let object = object as? LayoutAttributes else { return false }

            return super.isEqual(object)
                && object.style == style
        }
    }
}

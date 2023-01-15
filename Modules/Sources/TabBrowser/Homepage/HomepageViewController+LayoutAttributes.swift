import UIKit

extension HomepageViewController {
    class LayoutAttributes: UICollectionViewLayoutAttributes {
        /// A percent expansion of hero header.
        ///
        /// see ``HomepageViewController.HeroHeaderView.percentExpansion``
        var headerPercentExpansion: CGFloat = 0
        
        override func copy(with zone: NSZone? = nil) -> Any {
            let attributes = super.copy(with: zone) as! LayoutAttributes
            attributes.headerPercentExpansion = headerPercentExpansion
            return attributes
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let object = object as? LayoutAttributes,
                  super.isEqual(object)
            else { return false }
            
            return object.headerPercentExpansion == headerPercentExpansion
        }
    }
}

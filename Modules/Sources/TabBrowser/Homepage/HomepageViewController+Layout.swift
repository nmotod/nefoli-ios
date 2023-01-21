import UIKit

extension HomepageViewController {
    class Layout: UICollectionViewFlowLayout {
        override class var layoutAttributesClass: AnyClass { LayoutAttributes.self }

        /// A height of the top part of the hero header.
        /// It gets off screen if scrolled down.
        private var shrinkableHeaderHeight: CGFloat { HeroHeaderView.maximumHeight - HeroHeaderView.minimumHeight }

        private var minimumContentHeight: CGFloat {
            guard let collectionView = collectionView else { return 0 }

            let inset = collectionView.adjustedContentInset
            return collectionView.bounds.height
                - (inset.top + inset.bottom)
                + shrinkableHeaderHeight
        }

        override var collectionViewContentSize: CGSize {
            let contentSize = super.collectionViewContentSize

            return CGSize(
                width: contentSize.width,
                height: max(contentSize.height, minimumContentHeight)
            )
        }

        private let headerAttributes = LayoutAttributes(
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            with: IndexPath(item: 0, section: 0)
        )

        override func prepare() {
            guard let collectionView = collectionView,
                  !collectionView.bounds.isEmpty
            else {
                super.prepare()
                return
            }

            let minWidth = min(collectionView.bounds.width, collectionView.bounds.height)
            let xInset: CGFloat = 10

            minimumInteritemSpacing = 0
            minimumLineSpacing = 5

            sectionInset = .init(
                top: 15,
                left: xInset,
                bottom: 0,
                right: xInset
            )

            itemSize = .init(
                width: (minWidth - xInset * 2) / 4,
                height: Cell.preferredHeight
            )

            headerReferenceSize = CGSize(
                width: collectionView.bounds.width,
                height: HeroHeaderView.maximumHeight
            )

            super.prepare()

            invalidateHeaderFor(bounds: collectionView.bounds)
        }

        private func invalidateHeaderFor(bounds: CGRect) {
            guard let collectionView = collectionView else { return }

            let adjustedOffsetY = bounds.origin.y + collectionView.adjustedContentInset.top

            let percentExpansion = (shrinkableHeaderHeight - adjustedOffsetY) / shrinkableHeaderHeight
            headerAttributes.headerPercentExpansion = max(0, min(percentExpansion, 1))

            headerAttributes.frame = CGRect(
                x: 0,
                y: 0,
                width: bounds.width,
                height: HeroHeaderView.maximumHeight
            )

            headerAttributes.zIndex = 100

            if adjustedOffsetY < 0 {
                headerAttributes.frame.origin.y = adjustedOffsetY
                headerAttributes.frame.size.height = HeroHeaderView.maximumHeight - adjustedOffsetY

            } else if shrinkableHeaderHeight <= adjustedOffsetY {
                headerAttributes.frame.origin.y = adjustedOffsetY - shrinkableHeaderHeight
            }
        }

        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            guard var attributesArray = super.layoutAttributesForElements(in: rect) else { return nil }

            attributesArray = attributesArray.filter { attributes in
                attributes.representedElementKind != UICollectionView.elementKindSectionHeader
            }

            attributesArray.append(headerAttributes)

            return attributesArray
        }

        override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            if elementKind == UICollectionView.elementKindSectionHeader {
                return headerAttributes
            }

            let attributes = layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
            return attributes
        }

        override func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
            return true
        }

        override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
            let context = super.invalidationContext(forBoundsChange: newBounds)

            invalidateHeaderFor(bounds: newBounds)

            context.invalidateSupplementaryElements(
                ofKind: UICollectionView.elementKindSectionHeader,
                at: [headerAttributes.indexPath]
            )

            return context
        }
    }
}

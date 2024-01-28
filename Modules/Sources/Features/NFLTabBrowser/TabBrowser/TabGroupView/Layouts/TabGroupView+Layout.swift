import NFLDatabase
import UIKit

protocol TabGroupViewLayoutDelegate: UICollectionViewDelegate {
    func groupForTabGroupView(_ collectionView: UICollectionView) -> TabGroup?
}

extension TabGroupView {
    class Layout: UICollectionViewLayout {
        let style: Style

        var dropDestinationIndexPath: IndexPath?

        override class var layoutAttributesClass: AnyClass { LayoutAttributes.self }

        /// The array of attributes for items indexed by indexPath.item.
        /// Only supports one section.
        private var itemAttributesArray = [LayoutAttributes]()

        private var itemDisappearedAttributesStorage = [IndexPath: LayoutAttributes]()

        /// The dictionary of attributes indexed by element kind.
        /// Only supports one section.
        private var supplementaryAttributesByKind = [String: LayoutAttributes]()

        private var contentSize = CGSize.zero

        override var collectionViewContentSize: CGSize { contentSize }

        private var tabInToggle: Tab?

        func beginToggle(tab: Tab) {
            tabInToggle = tab
        }

        func endToggle() {
            tabInToggle = nil
        }

        // MARK: -

        init(style: Style = .collapsed) {
            self.style = style
            super.init()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Override methods

        override func prepare() {
            itemAttributesArray = []
            supplementaryAttributesByKind.removeAll()
            contentSize = .zero
            itemDisappearedAttributesStorage.removeAll()

            guard let collectionView = collectionView else { return }
            contentSize.height = collectionView.bounds.height

            let nItems = collectionView.numberOfItems(inSection: 0)

            let itemSize = CGSize(
                width: style.itemWidth,
                height: collectionView.bounds.height
            )

            itemAttributesArray.reserveCapacity(nItems)

            var elementX0 = style.contentInset.left

            setSupplementaryAttributes(kind: UICollectionView.elementKindSectionHeader) { attributes in
                attributes.style = style
                attributes.frame = CGRect(
                    x: elementX0,
                    y: 0,
                    width: style.headerWidth,
                    height: collectionView.bounds.height
                )

                elementX0 = attributes.frame.maxX
            }

            for i in 0 ..< nItems {
                //            let tab: Tab? = getTabAtIndex(i)

                let indexPath = IndexPath(item: i, section: 0)

                let itemAttributes = LayoutAttributes(forCellWith: indexPath)
                itemAttributes.style = style
                itemAttributes.zIndex = i * 2 + 1

                itemAttributes.frame = CGRect(
                    x: elementX0,
                    y: style.contentInset.top,
                    width: itemSize.width,
                    height: itemSize.height
                )

                elementX0 = itemAttributes.frame.maxX + style.interitemSpacing

                //            if let tab = tab {
                //                itemAttributes.frame.origin.y += CGFloat(tab.depth) * style.indentationWidthPerDepth
                //
                //                if let ancestor = tab.collapsedBy {
                //                    itemAttributes.isHidden = true
                //
                //                    if ancestor == tabInToggle {
                //                        if let ancestorIndex = group.firstIndex(of: ancestor) {
                //                            let ancestorAttributes = itemAttributesArray[ancestorIndex]
                //                            itemAttributes.frame = ancestorAttributes.frame
                //
                //                            let disappearedAttributes = itemAttributes.copy() as! LayoutAttributes
                //                            disappearedAttributes.isHidden = false
                //                            disappearedAttributes.alpha = 0
                //                            itemDisappearedAttributesStorage[indexPath] = disappearedAttributes
                //                        }
                //                    }
                //                }
                //            }

                itemAttributesArray.append(itemAttributes)

                assert(itemAttributesArray.count - 1 == i)
            }

            setSupplementaryAttributes(kind: UICollectionView.elementKindSectionFooter) { attributes in
                attributes.frame = CGRect(
                    x: elementX0,
                    y: 0,
                    width: 60,
                    height: collectionView.bounds.height
                )

                contentSize.width = attributes.frame.maxX
            }

            //        if isResizing, let indexPath = centerItemIndexPath, let attributes = itemAttributesStorage[indexPath] {
            //            collectionView.contentOffset.x = attributes.frame.minX - collectionView.bounds.width / 2 + centerItemOffsetX
            //        }
        }

        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            let attributesArray = [itemAttributesArray, Array(supplementaryAttributesByKind.values)].flatMap { array in
                array.filter { attributes in
                    attributes.frame.intersects(rect)
                }
            }

            return attributesArray
        }

        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            if indexPath.item > 0, indexPath.item < itemAttributesArray.count {
                return itemAttributesArray[indexPath.item]
            }
            return nil
        }

        override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at _: IndexPath) -> UICollectionViewLayoutAttributes? {
            // Ignore indexPath.
            return supplementaryAttributesByKind[elementKind]
        }

        override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
            guard let collectionView = collectionView else { return false }

            return newBounds.height != collectionView.bounds.height
        }

        // MARK: -

        private func setSupplementaryAttributes(kind: String, builder: (LayoutAttributes) -> Void) {
            assert(supplementaryAttributesByKind[kind] == nil)

            let attributes = LayoutAttributes(forSupplementaryViewOfKind: kind, with: IndexPath(item: 0, section: 0))
            attributes.style = style

            builder(attributes)

            supplementaryAttributesByKind[kind] = attributes
        }

        func indexPathForItem(at point: CGPoint) -> IndexPath? {
            for (i, attributes) in itemAttributesArray.enumerated() {
                // Only check a X coordinate.
                if attributes.frame.minX <= point.x, point.x <= attributes.frame.maxX {
                    return IndexPath(item: i, section: 0)
                }
            }

            return nil
        }

        //////////

        //    override func targetIndexPath(forInteractivelyMovingItem previousIndexPath: IndexPath, withPosition position: CGPoint) -> IndexPath {
        //        log.debug()
        //        return super.targetIndexPath(forInteractivelyMovingItem: previousIndexPath, withPosition: position)
        //    }
        //
        //    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        //        log.debug()
        //        return super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        //    }
        //
        override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)

            logger.debug("\(itemIndexPath): \(attributes?.frame.debugDescription ?? "()")")

            return attributes
        }

        override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            if let attributes = itemDisappearedAttributesStorage[itemIndexPath] {
                return attributes
            }

            let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)

            return attributes
        }
        //
        //    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        //        super.prepare(forCollectionViewUpdates: updateItems)
        //
        //        let strings = updateItems.map { (item) -> String in
        //            return "\(item.indexPathBeforeUpdate?.description ?? "") --> \(item.indexPathAfterUpdate?.description ?? "") (\(item.updateAction.rawValue))"
        //        }
        //
        //        log.debug(strings)
        //    }
        //
        //    override func finalizeCollectionViewUpdates() {
        //        super.finalizeCollectionViewUpdates()
        //        log.debug()
        //    }
        //
        //    override func invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths indexPaths: [IndexPath], previousIndexPaths: [IndexPath], movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext {
        //        log.debug()
        //        return super.invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths: indexPaths, previousIndexPaths: previousIndexPaths, movementCancelled: movementCancelled)
        //    }

        //////////////

        //    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        //        let contentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        //        log.debug(contentOffset)
        //        return contentOffset
        //    }
        //
        //    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        //        let contentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        //        log.debug(contentOffset)
        //        return contentOffset
        //    }

        //
        // Resize

        //    private(set) var isResizing = false
        //
        //    private var centerItemOffsetX: CGFloat = 0
        //    private var centerItemIndexPath: IndexPath?
        //
        //    func beginResizing() {
        //        isResizing = true
        //
        //        centerItemIndexPath = nil
        //
        //        guard let collectionView = collectionView else { return }
        //
        //        let center = CGPoint(
        //            x: collectionView.bounds.midX,
        //            y: 0
        //        )
        //
        //        let item = itemAttributesStorage.first { (_, attributes) in
        //            return attributes.frame.contains(center)
        //        }
        //        if let item = item {
        //            centerItemIndexPath = item.key
        //            centerItemOffsetX = collectionView.bounds.midX - item.value.frame.minX
        //        }
        //    }
        //
        //    func endResizing() {
        //        isResizing = false
        //    }
    }
}

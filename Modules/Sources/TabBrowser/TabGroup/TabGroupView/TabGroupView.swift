import Database
import UIKit
import Utils

protocol TabGroupViewDelegate: AnyObject {
    func tabGroupViewRequestsAddNewTab(_: TabGroupView)
}

public typealias TabGroupViewDependency = TabGroupViewCellDependency

class TabGroupView: UIView,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDragDelegate,
    UICollectionViewDropDelegate,
    TabGroupViewLayoutDelegate,
    TabGroupViewCellDelegate,
    UIGestureRecognizerDelegate
{
    private let dependency: TabGroupViewDependency

    //    private let tabStore = Container.shared.tabStore

//    private var log = defaultLogger

    private(set) var style: Style = .default

    var group: TabGroup? {
        didSet {
            groupTokens = [
                group?.observe { [weak self] change in
                    self?.didChangeTabGroup(change)
                },
                group?.observeChildren { [weak self] change in
                    self?.childrenDidChange(change)
                },
            ].compactMap { $0 }

//            collectionViewLayout.log = Logger(nfl_entity: group)

            reloadData()

            // Scroll to active tab.
            if let index = group?.activeTabIndex {
//                scrollTo(tab: activeTab, at: .centeredHorizontally, animated: false)
                collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }

    private var groupTokens = [NotificationToken]()

    weak var delegate: TabGroupViewDelegate?

    private let collectionViewLayout: Layout

    private(set) lazy var collectionView: UICollectionView = {
        let v = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)

        v.delegate = self
        v.dataSource = self
        v.dragDelegate = self
        v.dropDelegate = self

        v.dragInteractionEnabled = true
        v.isSpringLoaded = true
        v.backgroundColor = nil
        v.alwaysBounceHorizontal = true
        v.showsHorizontalScrollIndicator = false
        v.clipsToBounds = false

        return v
    }()

    private lazy var closeGestureRecognizer: DrawGestureRecognizer = {
        let recognizer = DrawGestureRecognizer(target: self, action: #selector(closeGestureDidRecognize(_:)))

        recognizer.delegate = self
        recognizer.numberOfStrokesRequired = 1
        recognizer.gridSize = 30
        recognizer.gestures = [
            DrawGesture(strokeDirections: [.down, .right], title: "Close TabBar Tab", handler: nil),
        ]
        return recognizer
    }()

    var closeRecognizingIndexPath: IndexPath?

    private let closeIndicator: CloseIndicatorView

    private var closeIndicatorCenterXConstraint: Constraint!

    private lazy var cellRegistration = UICollectionView.CellRegistration<Cell, Tab>(
        handler: { [weak self] cell, _, tab in
            guard let self = self,
                  let group = self.group
            else {
                fatalError()
            }

            cell.injectIfNeeded(dependency: self.dependency)

            cell.setup(
                delegate: self,
                tab: tab,
                isActive: group.activeTabId == tab.id
            )
        }
    )

    private lazy var headerRegistration = UICollectionView.SupplementaryRegistration<HeaderView>(
        elementKind: UICollectionView.elementKindSectionHeader,
        handler: { [weak self] headerView, _, _ in
            headerView.onMenuHandler = { [weak self] v in
                self?.showMenu(v)
            }
        }
    )

    private lazy var footerRegistration = UICollectionView.SupplementaryRegistration<FooterView>(
        elementKind: UICollectionView.elementKindSectionFooter,
        handler: { [weak self] footerView, _, _ in
            footerView.onAddHandler = { [weak self] v in
                self?.addNewTab(v)
            }
        }
    )

    // MARK: - Initializing

    init(frame: CGRect, dependency: TabGroupViewDependency) {
        self.dependency = dependency
        collectionViewLayout = .init(style: style)
        closeIndicator = .init(frame: .zero, style: style)

        super.init(frame: frame)

        // Ensure before use from data source methods.
        _ = cellRegistration
        _ = headerRegistration
        _ = footerRegistration

        // Display closeIndicator outside the view.
        clipsToBounds = false

        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addGestureRecognizer(closeGestureRecognizer)

        closeIndicator.isHidden = true
        addSubview(closeIndicator)
        closeIndicator.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.top)
            closeIndicatorCenterXConstraint = make.centerX.equalTo(0).constraint
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Close Gesture

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == closeGestureRecognizer else { return true }

        let p = gestureRecognizer.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: p) else {
            return false
        }

        closeRecognizingIndexPath = indexPath
        return true
    }

    @objc private func closeGestureDidRecognize(_ recognizer: DrawGestureRecognizer) {
        guard let closeRecognizingIndexPath = closeRecognizingIndexPath else { return }

        if recognizer.state == .ended, recognizer.recognizedGesture != nil {
            hideCloseIndicator()

            guard let group = group else { return }

            try! group.realm!.write {
                group.remove(at: closeRecognizingIndexPath.item)
            }

            return
        }

        switch recognizer.state {
        case .began:
            showCloseIndicator(at: closeRecognizingIndexPath)

        case .changed:
            if recognizer.recognizedGesture != nil {
                closeIndicator.state = .recognized
            }

        case .ended, .failed, .cancelled:
            hideCloseIndicator()

        default: ()
        }
    }

    private func showCloseIndicator(at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        closeIndicator.state = .recognizing

        let cellX = convert(cell.center, from: collectionView).x

        closeIndicatorCenterXConstraint.update(offset: cellX)
    }

    private func hideCloseIndicator() {
        closeIndicator.state = .hidden
    }

    // MARK: - Actions

    func setStyle(_ style: Style, animated: Bool) {
        let newLayout = Layout(style: style)

        collectionView.setCollectionViewLayout(newLayout, animated: animated)
    }

    @objc private func addNewTab(_: Any) {
        delegate?.tabGroupViewRequestsAddNewTab(self)
    }

    @objc private func showMenu(_: Any) {
        guard let window = window else { return }

        let controller = AnywhereAlertController()

        controller.addAction(UIAlertAction(title: NSLocalizedString("Close All Tabs in Group", comment: ""), style: .destructive, handler: { [weak self] _ in
            _ = self
//            guard let group = cell.group else { return }
//            self?.deleteGroup(group)
        }))

        controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))

        controller.show(on: window)
    }

    // MARK: -

    func groupForTabGroupView(_: UICollectionView) -> TabGroup? {
        return group
    }

    func reloadData() {
        collectionView.reloadData()
    }

    func scrollTo(tab: Tab, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard let indexPath = indexPathFor(tab: tab) else {
            return
        }

        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }

    func scrollToBottom(animated: Bool) {
        let bottomRect = CGRect(x: collectionView.contentSize.width - 1, y: collectionView.contentSize.height - 1,
                                width: 1, height: 1)
        collectionView.scrollRectToVisible(bottomRect, animated: animated)
    }

    // MARK: - Observing tab group

    private func didChangeTabGroup(_ change: ObjectChange<TabGroup>) {
        switch change {
        case .change:
            let changedProperties = change.changedProperties ?? []

            if changedProperties.contains(.activeTabId) && !changedProperties.contains(.children) {
                activeTabDidChange()
            }

        case .deleted:
            group = nil

        case .error: ()
        }
    }

    private func childrenDidChange(_ change: RealmCollectionChange<List<Tab>>) {
        switch change {
        case .initial:
            reloadData()

        case let .update(_, deletions, insertions, modifications):
            logger.debug("d=\(deletions),  i=\(insertions),  m=\(modifications)")

            for indexPath in deletions.map({ IndexPath(row: $0, section: 0) }) {
                if let cell = collectionView.cellForItem(at: indexPath) as? Cell {
                    cell.tab = nil
                }
            }

            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })

                // TODO:
//                collectionView.reloadItems(at: modifications.map{ IndexPath(row: $0, section: 0) })

            }, completion: { _ in
                // Do not use reloadItems() for performance.
                for i in modifications {
                    if let cell = self.collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? Cell {
                        cell.didChangeTab()
                    }
                }

                self.collectionView.collectionViewLayout.invalidateLayout()

                self.activeTabDidChange()
            })

        case .error: ()
        }
    }

    private func activeTabDidChange() {
        var newActiveCell: Cell?

        if let index = group?.activeTabIndex,
           let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? Cell
        {
            newActiveCell = cell
        }

        SystemLikeAnimator.animate(options: .allowUserInteraction) {
            for cell in self.visibleCells {
                cell.isActive = false
            }

            newActiveCell?.isActive = true

            self.layoutIfNeeded()
        }
    }

    // MARK: -

    private var visibleCells: [Cell] {
        return collectionView.visibleCells.compactMap { $0 as? Cell }
    }

    private func tabAt(_ indexPath: IndexPath, offset: Int = 0) -> Tab? {
        guard let group = group else { return nil }

        let index = indexPath.row + offset

        if index >= 0, index < group.count {
            return group[index]
        }

        return nil
    }

    private func indexPathFor(tab: Tab) -> IndexPath? {
        guard let index = group?.firstIndex(of: tab) else {
            return nil
        }

        return IndexPath(row: index, section: 0)
    }

    // MARK: - Cell delegate

    func tabGroupViewCell(_ cell: Cell, dragStateDidChange dragState: UICollectionViewCell.DragState) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        logger.debug("[\(indexPath.row)] dragStateDidChange --> \(dragState.rawValue)")
    }

    func tabGroupViewCellRequestsDelete(_: Cell) {}

    // MARK: - Collection view data source

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return group?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let group = group else {
            fatalError()
        }

        let tab = group[indexPath.item]
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: tab)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)

        case UICollectionView.elementKindSectionFooter:
            return collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)

        default:
            return UICollectionReusableView()
        }
    }

    // MARK: - Collection view delegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let group = group else { return }

        collectionView.deselectItem(at: indexPath, animated: false)

        try! group.realm!.write {
            group.activeTabIndex = indexPath.item
        }
    }

    // MARK: - Drag delegate

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning _: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let tab = tabAt(indexPath) else { return [] }

        logger.debug("itemsForBeginning row: \(indexPath.row)")

        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = tab

        collectionViewLayout.beginToggle(tab: tab)

        collectionView.performBatchUpdates({
            collectionViewLayout.invalidateLayout()

        }, completion: { _ in
            self.collectionViewLayout.endToggle()
        })

        return [dragItem]
    }

    func collectionView(_: UICollectionView, shouldSpringLoadItemAt _: IndexPath, with _: UISpringLoadedInteractionContext) -> Bool {
//        log.debug("\(indexPath)  \(context)")
        return false
    }

    func collectionView(_: UICollectionView, dragSessionIsRestrictedToDraggingApplication _: UIDragSession) -> Bool {
        // Allow drag only within the app.
        return true
    }

    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? Cell else { return nil }
        return cell.dragPreviewParameters()
    }

    func collectionView(_: UICollectionView, dragSessionAllowsMoveOperation _: UIDragSession) -> Bool {
        return true
    }

    // MARK: - Drop delegate

    func collectionView(_: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        // Accept only items that has tab.
        if session.items.first?.localObject is Tab {
            collectionViewLayout.dropDestinationIndexPath = destinationIndexPath

            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UICollectionViewDropProposal(operation: .cancel)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let group = group,
              let dropItem = coordinator.items.first,
              dropItem.dragItem.localObject is Tab
        else { return }

        let destinationIndexPath = coordinator.destinationIndexPath
            // Add to end
            ?? IndexPath(item: collectionView.numberOfItems(inSection: 0), section: 0)

        if let sourceIndexPath = dropItem.sourceIndexPath {
            // Move within one collectionView.
            logger.debug("move \(sourceIndexPath.row) --> \(destinationIndexPath.row)")

            try! group.realm!.write(withoutNotifying: groupTokens) {
                group.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
            }

            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }, completion: nil)

        } else {
            // Move from other collectionView to this one.
            logger.debug("move (other group) --> \(destinationIndexPath)")

//            try! group.realm!.write(withoutNotifying: groupTokens) {
//                tabStore.transfer(tab: tab, toGroup: group, isRecursive: true)
//            }

            collectionView.performBatchUpdates({
                collectionView.insertItems(at: [destinationIndexPath])
            }, completion: nil)
        }

        coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
    }

    // func collectionView(_: UICollectionView, dropSessionDidEnter _: UIDropSession) {}

    func collectionView(_: UICollectionView, dropSessionDidEnd _: UIDropSession) {
        collectionViewLayout.dropDestinationIndexPath = nil
    }

    func collectionView(_: UICollectionView, dropSessionDidExit _: UIDropSession) {
        collectionViewLayout.dropDestinationIndexPath = nil
    }
}

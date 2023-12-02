import Bookmarks
import Database
import Foundation
import ThemeSystem
import UIKit
import Utils

public typealias NewTabViewControllerDependency = UsesBookmarkStore & NewTabViewControllerCellDependency

protocol NewTabViewControllerDelegate: AnyObject {
    func newTabVC(_: NewTabViewController, openBookmark bookmark: BookmarkItem)

    func newTabVCForwardGestureDidRecognize(_: NewTabViewController)
}

class NewTabViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    enum Section: Int {
        case favorites
    }

    let dependency: NewTabViewControllerDependency

    private let bookmarkStore: BookmarkStore

    private let favoritesFolder: BookmarkItem

    weak var delegate: NewTabViewControllerDelegate?

    let allowsForwardGesture: Bool

    private let collectionViewLayout = Layout()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.backgroundColor = ThemeColors.background.color

        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self

        return collectionView
    }()

    private var dataSource: UICollectionViewDiffableDataSource<Section, BookmarkItem>?

    // MARK: - Initializer

    init(
        delegate: NewTabViewControllerDelegate?,
        allowsForwardGesture: Bool,
        dependency: NewTabViewControllerDependency
    ) {
        self.delegate = delegate
        self.allowsForwardGesture = allowsForwardGesture
        bookmarkStore = dependency.bookmarkStore
        favoritesFolder = dependency.bookmarkStore.favoritesFolder
        self.dependency = dependency

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setUpDataSource()

        if allowsForwardGesture {
            let interaction = ForwardPanGestureInteraction(contentView: collectionView) { [weak self] _ in
                guard let self = self else { return }

                self.delegate?.newTabVCForwardGestureDidRecognize(self)
            }

            view.addInteraction(interaction)
        }
    }

    private func setUpDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<Cell, BookmarkItem> { cell, _, item in
            cell.item = item
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<HeroHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { _, _, _ in }

        let dataSource = UICollectionViewDiffableDataSource<Section, BookmarkItem>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, item in
                guard let self else { return nil }

                let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
                cell.injectIfNeeded(dependency: self.dependency)
                return cell
            }
        )
        self.dataSource = dataSource

        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)

            default:
                return nil
            }
        }

        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.favorites])
        snapshot.appendItems(Array(favoritesFolder.children), toSection: .favorites)
        dataSource.apply(snapshot)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // MARK: - Collection view

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = favoritesFolder.children[indexPath.item]

        delegate?.newTabVC(self, openBookmark: item)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let i = indexPaths.first?.item else { return nil }

        let item = favoritesFolder.children[i]

        return UIContextMenuConfiguration(actionProvider: { _ in
            return UIMenu(children: [
                UIAction(
                    title: NSLocalizedString("Edit", comment: ""),
                    image: UIImage(systemName: "square.and.pencil"),
                    handler: { [weak self] _ in
                        self?.editBookmarkItem(item)
                    }
                ),
                UIAction(title: NSLocalizedString("Delete", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive, handler: { _ in
                }),
            ])
        })
    }

    private func editBookmarkItem(_ item: BookmarkItem) {
        let controller = BookmarkEditController(
            editingItem: item,
            bookmarkStore: bookmarkStore,
            onDismiss: { [weak self] in
                self?.dismiss(animated: true)
            }
        )

        present(controller, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? Cell else { return nil }

        return UITargetedPreview(view: cell, parameters: cell.dragPreviewParameters)
    }

    // MARK: - Collection view drag delegate

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = favoritesFolder.children[indexPath.item]

        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = item
        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionAllowsMoveOperation session: UIDragSession) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? Cell else { return nil }

        return cell.dragPreviewParameters
    }

    // MARK: - Collection view drop delegate

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return .init(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func collectionView(_ collectionView: UICollectionView, dropPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? Cell else { return nil }

        return cell.dragPreviewParameters
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        // Support only reordering within itself
        guard let dataSource,
              let dropItem = coordinator.items.first,
              let sourceIndexPath = dropItem.sourceIndexPath,
              let destinationIndexPath = coordinator.destinationIndexPath else { return }

        try! favoritesFolder.realm!.write {
            favoritesFolder.children.move(from: sourceIndexPath.item, to: destinationIndexPath.item)
        }

        var snapshot = dataSource.snapshot(for: .favorites)
        snapshot.deleteAll()
        snapshot.append(Array(favoritesFolder.children))
        dataSource.apply(snapshot, to: .favorites, animatingDifferences: true)

        coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
    }
}

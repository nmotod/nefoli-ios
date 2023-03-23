import Database
import Foundation
import Theme
import UIKit
import Utils

public typealias NewTabViewControllerDependency = UsesBookmarkFolders & NewTabViewControllerCellDependency

protocol NewTabViewControllerDelegate: AnyObject {
    func newTabVC(_: NewTabViewController, openBookmark bookmark: BookmarkItem)

    func newTabVCForwardGestureDidRecognize(_: NewTabViewController)
}

class NewTabViewController: UIViewController, UICollectionViewDelegate {
    enum Section: Int {
        case favorites
    }

    let dependency: NewTabViewControllerDependency

    weak var delegate: NewTabViewControllerDelegate?

    let allowsForwardGesture: Bool

    private let collectionViewLayout = Layout()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.backgroundColor = Colors.background.color
        return collectionView
    }()

    let favoritesFolder: BookmarkItem

    private var dataSource: UICollectionViewDiffableDataSource<Section, BookmarkItem>?

    // MARK: - Initializer

    init(
        delegate: NewTabViewControllerDelegate?,
        allowsForwardGesture: Bool,
        dependency: NewTabViewControllerDependency
    ) {
        self.delegate = delegate
        self.allowsForwardGesture = allowsForwardGesture
        favoritesFolder = dependency.favoritesFolder
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
}

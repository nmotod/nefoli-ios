import Database
import Foundation
import Theme
import UIKit
import Utilities

public typealias HomepageViewControllerDependency = UsesBookmarkFolders

protocol HomepageViewControllerDelegate: AnyObject {
    func homepageVC(_: HomepageViewController, openBookmark bookmark: BookmarkItem)
    
    func homepageVCForwardGestureDidRecognize(_: HomepageViewController)
}

class HomepageViewController: UIViewController, UICollectionViewDelegate {
    enum Section: Int {
        case favorites
    }
    
    weak var delegate: HomepageViewControllerDelegate?
    
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
        delegate: HomepageViewControllerDelegate?,
        allowsForwardGesture: Bool,
        dependency: HomepageViewControllerDependency
    ) {
        self.delegate = delegate
        self.allowsForwardGesture = allowsForwardGesture
        favoritesFolder = dependency.favoritesFolder
        
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
                
                self.delegate?.homepageVCForwardGestureDidRecognize(self)
            }
            
            view.addInteraction(interaction)
        }
    }

    private func setUpDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<Cell, BookmarkItem> { cell, _, item in
            cell.item = item
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<HeroHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) { _, _, _ in }

        let dataSource = UICollectionViewDiffableDataSource<Section, BookmarkItem>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = favoritesFolder.children[indexPath.item]
        
        delegate?.homepageVC(self, openBookmark: item)
    }
}

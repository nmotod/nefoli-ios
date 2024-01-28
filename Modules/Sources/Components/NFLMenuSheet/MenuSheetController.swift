import Foundation
import NFLThemeSystem
import SnapKit
import UIKit
import Utils

private let backgroundColor = ThemeColors.backgroundDark.color

public class MenuSheetController: UIViewController, UICollectionViewDelegate, UIAdaptivePresentationControllerDelegate {
    public let webpageMetadata: WebpageMetadata?

    public let actionGroups: [[UIAction]]

    // MARK: - Initializers

    public init(
        webpageMetadata: WebpageMetadata?,
        actionGroups: [[UIAction]]
    ) {
        self.webpageMetadata = webpageMetadata
        self.actionGroups = actionGroups

        super.init(nibName: nil, bundle: nil)

        sheetPresentationController?.detents = [
            .medium(),
            .large(),
        ]
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var headerView: MenuSheetHeaderView = {
        let v = MenuSheetHeaderView()
        v.titleLabel.text = webpageMetadata?.title
        v.urlLabel.text = webpageMetadata?.url.absoluteString

        v.onClose = { [weak self] in
            self?.dismiss(animated: true)
        }

        return v
    }()

    private let collectionViewLayout: UICollectionViewCompositionalLayout = .init(sectionProvider: { _, layoutEnv in
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.backgroundColor = backgroundColor
        listConfig.showsSeparators = true
        listConfig.separatorConfiguration = .init(listAppearance: .grouped)
        listConfig.separatorConfiguration.color = ThemeColors.tableSeparator.color

        let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnv)
        section.contentInsets.top = 15
        section.contentInsets.bottom = 7
        return section
    })

    private lazy var cellRegistration: UICollectionView.CellRegistration<MenuSheetActionCell, UIAction> = .init { cell, _, action in
        cell.setup(action: action, afterAction: .init(handler: { [weak self] _ in
            self?.dismissIfPossible()
        }))
    }

    private lazy var collectionView: UICollectionView = {
        let v = UICollectionView(
            frame: UIScreen.main.bounds,
            collectionViewLayout: collectionViewLayout
        )
        v.delegate = self
        return v
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, UIAction> = .init(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
        guard let self else { return nil }

        return collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: itemIdentifier)
    }

    // MARK: - View lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        _ = cellRegistration
        _ = dataSource

        let vStack = UIStackView(arrangedSubviews: [
            headerView,
            collectionView,
        ])
        vStack.axis = .vertical
        view = vStack

        vStack.backgroundColor = backgroundColor

        var snapshot = dataSource.snapshot()
        snapshot.appendSections(Array(0 ..< (actionGroups.count)))

        for (sectionIndex, actions) in actionGroups.enumerated() {
            snapshot.appendItems(actions, toSection: sectionIndex)
        }

        dataSource.apply(snapshot)
    }

    // MARK: - UIAdaptivePresentationControllerDelegate

    public func presentationControllerDidDismiss(_: UIPresentationController) {
        dismiss(animated: true)
    }

    // MARK: -

    /// Remember whether show() has been called
    /// presentingViewController cannot be used for UIActivtyVC (in iOS 17.0.1)
    private var isShowCalled = false

    // TODO: remove detents
    public func show(_ childViewController: UIViewController, animated: Bool) {
        isShowCalled = true

        // to detect interactive dismissal
        childViewController.presentationController?.delegate = self

        present(childViewController, animated: true)
    }

    private func dismissIfPossible() {
        if !isShowCalled {
            dismiss(animated: true)
        }
    }
}

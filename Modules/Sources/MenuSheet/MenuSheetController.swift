import Foundation
import SnapKit
import Theme
import UIKit
import Utils

private let backgroundColor = Colors.backgroundDark.color

public class MenuSheetController: UIViewController, UICollectionViewDelegate, UIAdaptivePresentationControllerDelegate {
    public let webpageMetadata: WebpageMetadata?

    public let actionGroups: [[ExecutableAction]]

    private lazy var headerView: HeaderView = {
        let v = HeaderView()
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

        let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnv)
        section.contentInsets.top = 15
        section.contentInsets.bottom = 7
        return section
    })

    private let cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, ExecutableAction> = .init { cell, _, action in
        var content = cell.defaultContentConfiguration()

        content.text = action.title
        content.textProperties.font = .systemFont(ofSize: 15)
        content.textProperties.color = Colors.textNormal.color

        content.image = action.image
        content.imageProperties.preferredSymbolConfiguration = .init(
            pointSize: 18,
            weight: .regular
        )
        content.imageProperties.tintColor = Colors.tint.color

        cell.contentConfiguration = content

        var background = cell.defaultBackgroundConfiguration()
        background.backgroundColor = Colors.background.color
        cell.backgroundConfiguration = background
    }

    private lazy var collectionView: UICollectionView = {
        let v = UICollectionView(
            frame: UIScreen.main.bounds,
            collectionViewLayout: collectionViewLayout
        )
        v.delegate = self
        return v
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, ExecutableAction> = .init(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
        guard let self = self else { return nil }

        return collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: itemIdentifier)
    }

    // MARK: - Initializers

    public init(
        webpageMetadata: WebpageMetadata?,
        actionGroups: [[ExecutableAction]]
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

    // MARK: - View lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()

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

    // MARK: - Collection view delegate

    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action = actionGroups[indexPath.section][indexPath.item]

        action.execute(.init(viewController: self))

        if let presentedViewController = presentedViewController {
            if presentedViewController.presentationController?.delegate != nil {
                print("\(type(of: self)) WARNING: presentedViewController.presentationController.delegate is already set")

            } else {
                presentedViewController.presentationController?.delegate = self
            }

        } else {
            dismiss(animated: true)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        cell.contentView.backgroundColor = .init(white: 1, alpha: 0.05)
    }

    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        cell.contentView.backgroundColor = nil
    }

    // MARK: - UIAdaptivePresentationControllerDelegate

    public func presentationControllerDidDismiss(_: UIPresentationController) {
        dismiss(animated: true)
    }
}

import Bookmarks
import CommandSystem
import Database
import Foundation
import RealmSwift
import SettingsUI
import Theme
import UIKit
import Utils

public typealias TabGroupControllerDependency = UsesSettings & TabGroupViewDependency & TabViewControllerDependency & SettingsControllerDependency

public class TabGroupController: UIViewController, TabGroupViewDelegate, TabViewControllerDelegate, UsesSettings {
    let dependency: TabGroupControllerDependency

    public let settings: Settings

    private var rootView: RootView?

    var group: TabGroup? {
        didSet {
            groupDidSet()
        }
    }

    private var groupTokens: [NotificationToken] = []

    private(set) var activeVC: TabViewController?

    private var viewControllersByTabId: [String: TabViewController] = [:]

    override public var preferredStatusBarStyle: UIStatusBarStyle { ThemeValues.preferredStatusBarStyle }

    private lazy var drawGestureInteraction: DrawGestureInteraction = {
        let settings: [([DrawGesture.Direction], any CommandProtocol)] = [
            ([.down, .right], TabGroupCommand.closeActiveTab),
            ([.down, .right, .up], TabGroupCommand.restoreClosedTab),
            ([.right, .down, .left, .up], TabCommand.reload),
            ([.right, .down, .left, .up, .right], TabCommand.reload),
        ]

        let gestures = settings.map { setting in
            let (directions, command) = setting

            return DrawGesture(
                strokeDirections: directions,
                title: command.title,
                handler: { [weak self] gesture in
                    try! self?.executeAny(command: command, sender: gesture)
                }
            )
        }

        return DrawGestureInteraction(gestures: gestures)
    }()

    public init(group: TabGroup?, dependency: TabGroupControllerDependency) {
        self.group = group
        self.dependency = dependency
        settings = dependency.settings

        super.init(nibName: nil, bundle: nil)

        groupDidSet()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let rootView = RootView(frame: UIScreen.main.bounds, dependency: dependency)
        view = rootView
        self.rootView = rootView

        rootView.tabGroupView.delegate = self
        rootView.tabGroupView.group = group

        activeTabDidChange()

        rootView.containerView.addInteraction(drawGestureInteraction)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        applySafeAreaInsetsToChildren()
    }

    private func applySafeAreaInsetsToChildren() {
        guard let rootView = rootView else { return }

        let toolbarY0 = view.convert(CGPoint.zero, from: rootView.stickyToolbar).y
        let bottomInset = view.bounds.height - toolbarY0 - view.safeAreaInsets.bottom

        for childVC in children {
            childVC.additionalSafeAreaInsets.bottom = bottomInset
        }
    }

    func showMenuSheet() {
        let cmmandGroups: [[any CommandProtocol]] = [
            [
                TabCommand.goBack,
                TabCommand.goForward,
            ],
            [
                TabGroupCommand.bookmarks,
                TabGroupCommand.tabs,
            ],
            [
                TabCommand.share,
                TabCommand.openInDefaultApp,
                TabCommand.addBookmark,
            ],
            [
                TabGroupCommand.settings,
            ],
        ]

        let actionGroups = cmmandGroups.map { types in
            types.map { makeUIAction(for: $0) }.compactMap { $0 }
        }

        let menuSheet = MenuSheetController(
            webpageMetadata: activeVC?.webpageMetadata,
            actionGroups: actionGroups
        )
        present(menuSheet, animated: true)
    }

    func closeActiveTab() {
        guard let group = group,
              let index = group.activeTabIndex
        else { return }

        activeVC?.tab = nil

        try! group.realm?.write(withoutNotifying: groupTokens) {
            group.remove(at: index)
        }

        activeTabDidChange()
    }

    private func groupDidSet() {
        groupTokens = []

        guard let group = group else {
            return
        }

        groupTokens.append(group.observe { [weak self] change in
            guard let self = self else { return }

            Task { @MainActor in
                if case let .change(_, changes) = change {
                    let properties = changes.compactMap { TabGroup.Property(rawValue: $0.name) }

                    if properties.contains(.activeTabId) {
                        self.activeTabDidChange()
                    }
                }
            }
        })

        groupTokens.append(group.children.observe { [weak self] change in
            guard let self = self else { return }

            Task { @MainActor in
                switch change {
                case .update:
                    // TODO: check active
                    self.pruneViewControllers()

                case .initial: ()
                case .error: ()
                }
            }
        })
    }

    private func ensureVC(tab: Tab) -> TabViewController {
        if let vc = viewControllersByTabId[tab.id] {
            return vc
        }

        let tabVC = TabViewController(
            tab: tab,
            delegate: self,
            dependency: dependency
        )

        viewControllersByTabId[tab.id] = tabVC

        return tabVC
    }

    private func activeTabDidChange() {
        guard let group = group,
              let rootView = rootView
        else {
            return
        }

        let tab = group.activeTabIndex.map { group.children[$0] }

        if let activeTabID = activeVC?.tab?.id, activeTabID == tab?.id {
            return
        }

        let oldVC = activeVC

        oldVC?.willMove(toParent: nil)

        if let tab = tab {
            let newVC = ensureVC(tab: tab)
            activeVC = newVC

            addChild(newVC)

            rootView.containerView.addSubview(newVC.view)
            newVC.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            setToolbarItems(from: [
                TabCommand.goBack,
                TabCommand.goForward,
                TabGroupCommand.menuSheet,
                TabGroupCommand.bookmarks,
                TabGroupCommand.tabs,
            ])

            newVC.didMove(toParent: self)

            applySafeAreaInsetsToChildren()
            newVC.tabDidActivate(stickyBottomBar: rootView.stickyToolbar)
        }

        oldVC?.viewIfLoaded?.removeFromSuperview()
        oldVC?.removeFromParent()
    }

    private func pruneViewControllers() {
        guard let group = group else { return }

        let prunedIds = Set(viewControllersByTabId.keys).subtracting(group.children.map(\.id))

        for id in prunedIds {
            guard let vc = viewControllersByTabId[id] else { continue }

            if vc.tab?.isInvalidated ?? false {
                vc.tab = nil
            }

            viewControllersByTabId.removeValue(forKey: id)
        }

        activeTabDidChange()
    }

    private func setToolbarItems(from commands: [any CommandProtocol]) {
        guard let toolbar = rootView?.toolbar else { return }

        let items = commands.compactMap(makeBarButtonItem(for:))

        toolbar.items = items.flatMap { item -> [UIBarButtonItem] in
            [
                item,
                UIBarButtonItem.flexibleSpace(),
            ]
        }.dropLast()
    }

    // MARK: - TabGroupView

    func tabGroupView(_: TabGroupView, didSelectTabAt index: Int) {
        guard let group = group else { return }

        try! group.realm!.write {
            group.activeTabId = group.children[index].id
        }
    }

    func tabGroupViewRequestsAddNewTab(_: TabGroupView) {
        let tab = Tab(initialURL: InternalURL.home.url)

        try! open(tab: tab, options: .init(
            activate: true,
            position: .end
        ))
    }

    public func open(tab: Tab, options: TabGroup.AddingOptions) throws {
        guard let group = group else { fatalError() }

        try group.realm!.write {
            group.add(tab: tab, options: options)
        }
    }

    func showSettings(_ sender: Any?) {
        let sender = sender as? UIResponder

        let settingsController = SettingsController(dependency: dependency)

        if let menuSheet = sender?.nfl_findResponder(of: MenuSheetController.self) {
            menuSheet.show(settingsController, detents: [.large()], animated: true)
        } else {
            present(settingsController, animated: true)
        }
    }

    func showBookmarks(_ sender: Any?) {
        let sender = sender as? UIResponder

        let bookmarkController = BookmarkManageController(
            bookmarkManager: dependency.bookmarkManager,
            onOpen: { [weak self] item in
                guard let self, let url = item.url else { return }

                let tab = Tab(initialURL: url)
                try! self.open(tab: tab, options: .init(activate: true, position: .end))
            }
        )

        if let menuSheet = sender?.nfl_findResponder(of: MenuSheetController.self) {
            menuSheet.show(bookmarkController, detents: [.large()], animated: true)
        } else {
            present(bookmarkController, animated: true)
        }
    }

    private var goBackActionStateCancellable: Any?
    private var goForwardActionStateCancellable: Any?

    func makeBarButtonItem(for command: any CommandProtocol) -> UIBarButtonItem? {
        guard let uiAction = makeUIAction(for: command) else {
            return nil
        }

        let item = UIBarButtonItem(primaryAction: uiAction)

        if let action = command as? TabCommand {
            switch action {
            case .goBack:
                // TODO: make subclass of UIBarButtonItem that can have a cancallable
                goBackActionStateCancellable = activeVC?.canGoBackPublisher.sink { [weak item] isEnabled in
                    item?.isEnabled = isEnabled
                }

            case .goForward:
                goForwardActionStateCancellable = activeVC?.canGoForwardPublisher.sink { [weak item] isEnabled in
                    item?.isEnabled = isEnabled
                }

            default: ()
            }
        }

        return item
    }

    // MARK: - Tab View Controller Delegate

    func tabVC(_ tabVC: TabViewController, searchWeb text: String) {
        guard let url = buildSearchURL(text: text) else {
            return
        }

        let tab = Tab(initialURL: url)
        try! open(tab: tab, options: .init(activate: true, position: .afterActive))
    }
}

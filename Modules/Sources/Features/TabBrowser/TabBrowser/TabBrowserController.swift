import ActionSystem
import Bookmark
import Database
import Foundation
import MenuSheet
import RealmSwift
import Settings
import TabBrowserCore
import ThemeSystem
import UIKit
import Utils

public typealias TabBrowserControllerDependency = UsesSettings & UsesTabStore & TabGroupViewDependency & TabViewControllerDependency & SettingsControllerDependency

public class TabBrowserController: UIViewController, TabGroupViewDelegate, TabViewControllerDelegate, UsesSettings, UsesTabStore {
    let dependency: TabBrowserControllerDependency

    public let settings: Settings

    public let tabStore: TabStore

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
        let settings: [([DrawGesture.Direction], any ActionTypeProtocol)] = [
            ([.down, .right], TabBrowserActionType.closeActiveTab),
            ([.down, .right, .up], TabBrowserActionType.restoreClosedTab),
            ([.right, .down, .left, .up], TabActionType.reload),
            ([.right, .down, .left, .up, .right], TabActionType.reload),
        ]

        let gestures = settings.map { setting in
            let (directions, actionType) = setting

            return DrawGesture(
                strokeDirections: directions,
                title: actionType.title,
                handler: { [weak self] gesture in
                    try! self?.dispatchAnyAction(type: actionType, sender: gesture)
                }
            )
        }

        return DrawGestureInteraction(gestures: gestures)
    }()

    public init(group: TabGroup?, dependency: TabBrowserControllerDependency) {
        self.group = group
        self.dependency = dependency
        settings = dependency.settings
        tabStore = dependency.tabStore

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
        let cmmandGroups: [[any ActionTypeProtocol]] = [
            [
                TabBrowserActionType.bookmarks,
                TabBrowserActionType.tabs,
            ],
            [
                TabActionType.share,
                TabActionType.openInDefaultApp,
                TabActionType.addBookmark,
                TabActionType.translate,
                TabActionType.hatenaBookmark,
            ],
            [
                TabBrowserActionType.settings,
            ],
        ]

        let actionGroups = cmmandGroups.map { types in
            types.map { makeUIAction(type: $0) }.compactMap { $0 }
        }

        let menuSheet = MenuSheetController(
            webpageMetadata: activeVC?.webpageMetadata,
            actionGroups: actionGroups
        )
        present(menuSheet, animated: true)
    }

    func closeActiveTab() {
        guard let index = group?.activeTabIndex else { return }

        closeTab(at: index)
    }

    func closeTab(at index: Int) {
        guard let group = group else { return }

        let willCloseActiveTab = index == group.activeTabIndex

        if willCloseActiveTab {
            activeVC?.tab = nil
        }

        try! group.realm?.write(withoutNotifying: groupTokens) {
            group.close(at: index, store: tabStore)
        }

        if willCloseActiveTab {
            activeTabDidChange()
        }

        pruneViewControllers()
    }

    func restoreClosedTab(_ sender: Any?) {
        guard let group = group,
              let last = tabStore.closedTabs.last
        else { return }

        try! group.realm!.write(withoutNotifying: groupTokens) {
            tabStore.closedTabs.removeLast()
            group.add(tab: last, options: .init(activate: true, position: .afterActive))
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

        tabVC.setOmnibarButtons(
            left: makeTabActionButton(type: TabActionType.goBack, for: tabVC),
            right: makeActionButton(type: TabBrowserActionType.menuSheet)
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

            rootView.setTabStickyBar(newVC.stickyBar)

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

    private func preload(tab: Tab) {
        guard let rootView = rootView else {
            return
        }

        let newVC = ensureVC(tab: tab)

        addChild(newVC)

        rootView.preloadingView.addSubview(newVC.view)
        newVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        newVC.didMove(toParent: self)

        applySafeAreaInsetsToChildren()
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

    func tabGroupView(_: TabGroupView, requestsCloseTabAt index: Int) {
        closeTab(at: index)
    }

    public func open(tab: Tab, options: TabGroup.AddingOptions) throws {
        guard let group = group else { fatalError() }

        try group.realm!.write(withoutNotifying: groupTokens) {
            group.add(tab: tab, options: options)
        }

        if options.activate {
            activeTabDidChange()

        } else {
            preload(tab: tab)
        }
    }

    func showSettings(_ sender: Any?) {
        let sender = sender as? UIResponder

        let settingsController = SettingsController(dependency: dependency)

        if let menuSheet = sender?.nfl_findResponder(of: MenuSheetController.self) {
            menuSheet.show(settingsController, animated: true)
        } else {
            present(settingsController, animated: true)
        }
    }

    func showBookmarks(_ sender: Any?) {
        let sender = sender as? UIResponder

        let bookmarkController = BookmarkManageController(
            bookmarkStore: dependency.bookmarkStore,
            onOpen: { [weak self] item in
                guard let self, let url = item.url else { return }

                let tab = Tab(initialURL: url)
                try! self.open(tab: tab, options: .init(activate: true, position: .end))
            },
            onDismiss: { [weak self] in
                self?.dismiss(animated: true)
            }
        )

        if let menuSheet = sender?.nfl_findResponder(of: MenuSheetController.self) {
            menuSheet.show(bookmarkController, animated: true)
        } else {
            present(bookmarkController, animated: true)
        }
    }

    // MARK: - Tab View Controller Delegate

    public func tabVC(_ tabVC: TabViewController, searchWeb text: String) {
        guard tabVC == activeVC,
              let url = buildSearchURL(text: text)
        else {
            return
        }

        let tab = Tab(initialURL: url)
        try! open(tab: tab, options: .init(activate: true, position: .afterActive))
    }

    public func tabVC(_ tabVC: TabViewController, willShowNewTabVC newTabVC: NewTabViewController) {
        newTabVC.topToolbarItems = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(primaryAction: makeUIAction(type: TabBrowserActionType.bookmarks)),
            UIBarButtonItem(primaryAction: makeUIAction(type: TabBrowserActionType.settings)),
        ]
    }

    public func open(tab: Tab, from tabVC: TabViewController) {
        try! open(tab: tab, options: .init(activate: false, position: .afterActive))
    }
}

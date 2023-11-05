import Bookmarks
import Combine
import Database
import Foundation
import RealmSwift
import UIKit
import Utils
import WebKit

public typealias TabViewControllerDependency = UsesWebViewManager & UsesScreenshotManager & NewTabViewControllerDependency

protocol TabViewControllerDelegate: AnyObject {
    func tabVC(_ tabVC: TabViewController, searchWeb text: String)

    func tabVCDidChangeAddressBarContent(_ tabVC: TabViewController)

    func tabVCDidStartLoading(_ tabVC: TabViewController)

    func tabVCDidFinishLoading(_ tabVC: TabViewController)
}

class TabViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, NewTabViewControllerDelegate, AddressEditViewControllerDelegate {
    private let dependency: TabViewControllerDependency

    private let webViewManager: WebViewManager

    private let screenshotManager: ScreenshotManager

    var tab: Tab? {
        didSet {
            tabDidSet()
        }
    }

    private var tabToken: NotificationToken?

    weak var delegate: TabViewControllerDelegate?

    private var rootView: RootView!

    private let webViewContainerController = UIViewController()

    private var webView: WKWebView?

    private var webViewKVObservations: [NSKeyValueObservation] = []

    private var stickyInteraction: WebViewStickyInteraction?

    private lazy var linkLongPressGestureRecognizer = WebLinkLongPressGestureRecognizer { [weak self] recognizer in
        guard recognizer.state == .began,
              let linkURL = recognizer.pressingLinkURL,
              let self = self,
              let tab = self.tab
        else { return }

        try! tab.realm!.write {
            tab.group!.add(tab: .init(initialURL: linkURL), options: .init(
                activate: false,
                position: .afterActive
            ))
        }
    }

    private let canGoBackSubject = CurrentValueSubject<Bool, Never>(false)

    var canGoBackPublisher: AnyPublisher<Bool, Never> {
        return canGoBackSubject.eraseToAnyPublisher()
    }

    var canGoBack: Bool { canGoBackSubject.value }

    private let canGoForwardSubject = CurrentValueSubject<Bool, Never>(false)

    var canGoForwardPublisher: AnyPublisher<Bool, Never> {
        return canGoForwardSubject.eraseToAnyPublisher()
    }

    var canGoForward: Bool {
        return canGoForwardSubject.value
    }

    private var stickyBottomBar: StickyContainerView? {
        didSet {
            stickyInteraction?.bottomBar = stickyBottomBar
            stickyInteraction?.update(isInteractive: false)
        }
    }

    var isLoading: Bool { webView?.isLoading ?? false }

    var progressProvider: ProgressBar.ProgressProvider {
        return { [weak self] in
            self?.webView?.estimatedProgress ?? 0
        }
    }

    init(
        tab: Tab,
        delegate: TabViewControllerDelegate?,
        dependency: TabViewControllerDependency
    ) {
        self.tab = tab
        self.delegate = delegate
        self.dependency = dependency
        webViewManager = dependency.webViewManager
        screenshotManager = dependency.screenshotManager

        super.init(nibName: nil, bundle: nil)

        tabDidSet()

        // TODO: Allow setting light/dark
        // overrideUserInterfaceStyle = .light
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func loadView() {
        let rootView = RootView(frame: UIScreen.main.bounds)
        self.rootView = rootView
        view = rootView

        rootView.addGestureRecognizer(linkLongPressGestureRecognizer)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Show newTabVC if needed

        Task { @MainActor in
            let webView = await webViewManager.getWebView(frame: view.bounds)
            self.webView = webView
            webViewContainerController.view = webView

            addChild(webViewContainerController)

            stickyInteraction = WebViewStickyInteraction(
                webView: webView,
                topBar: nil,
                bottomBar: stickyBottomBar
            )
            webView.scrollView.delegate = stickyInteraction

            webView.uiDelegate = self
            webView.navigationDelegate = self

            self.webViewKVObservations = [
                webView.observe(\.url) { [weak self] _, _ in
                    guard let self = self else { return }

                    Task { @MainActor in
                        self.addressDidChange()
                        self.titleOrURLDidChange()
                    }
                },
                webView.observe(\.title) { [weak self] _, _ in
                    guard let self = self else { return }

                    Task { @MainActor in
                        self.titleOrURLDidChange()
                    }
                },
                webView.observe(\.hasOnlySecureContent) { [weak self] _, _ in
                    guard let self = self else { return }

                    Task { @MainActor in
                        self.addressDidChange()
                    }
                },
                webView.observe(\.canGoBack) { [weak self] webView, _ in
                    guard let self = self else { return }

                    Task { @MainActor in
                        self.canGoBackSubject.send(webView.canGoBack)
                    }
                },
                webView.observe(\.canGoForward) { [weak self] webView, _ in
                    guard let self = self else { return }

                    Task { @MainActor in
                        self.canGoForwardSubject.send(webView.canGoForward)
                    }
                },
            ]

            rootView.showWebView(webView)

            if let url = tab?.current?.url ?? tab?.initialURL {
                _ = webView.load(URLRequest(url: url))
            }

            webView.nfl_stickyInsets = webView.safeAreaInsets

            webViewContainerController.didMove(toParent: self)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        webViewContainerController.additionalSafeAreaInsets.top = rootView.addressBar.frame.height
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        stickyInteraction?.update(isInteractive: false)
    }

    // MARK: - Actions

    func share(_ sender: Any?) {
        guard let webpageMetadata = webpageMetadata else { return }
        let sender = sender as? UIResponder

        let activityVC = UIActivityViewController(activityItems: [webpageMetadata], applicationActivities: [])

        if let menuSheet = sender?.nfl_findResponder(of: MenuSheetController.self) {
            menuSheet.show(activityVC, animated: true)
        } else {
            present(activityVC, animated: true)
        }
    }

    func editAddress(_ sender: Any?) {
        (sender as? UIResponder)?.nfl_findResponder(of: UIViewController.self)?.dismiss(animated: true)

        let url = webView?.url ?? tab?.initialURL

        let editVC = AddressEditViewController(initialURL: url, delegate: self)
        present(editVC, animated: true)
    }

    func openInDefaultApp() {
        guard let url = webView?.url else { return }

        UIApplication.shared.open(url)
    }

    func addBookmark(_ sender: Any?) {
        let sender = sender as? UIResponder

        let item = BookmarkItem()
        item.kind = .bookmark
        item.title = webView?.title ?? ""
        item.url = webView?.url

        let editController = BookmarkEditController(
            editingItem: item,
            bookmarkStore: dependency.bookmarkStore,
            onDismiss: { [weak self] in
                // Dismiss the menu sheet together
                self?.dismiss(animated: true)
            }
        )

        if let menuSheet = sender?.nfl_findResponder(of: MenuSheetController.self) {
            menuSheet.show(editController, animated: true)
        } else {
            present(editController, animated: true)
        }
    }

    func goBack(_ sender: Any?) {
        webView?.goBack()
    }

    func goForward(_ sender: Any?) {
        webView?.goForward()
    }

    func reload(_ sender: Any?) {
        webView?.reload()
    }

    // MARK: - Tab lifecycle

    private func tabDidSet() {
        tabToken = tab?.observe { [weak self] change in
            guard let self = self else { return }

            switch change {
            case .deleted:
                self.tab = nil

            case .change: ()
            case .error: ()
            }
        }
    }

    func tabDidActivate(stickyBottomBar: StickyContainerView) {
        self.stickyBottomBar = stickyBottomBar
    }

    // MARK: -

    var webpageMetadata: WebpageMetadata? {
        guard let tab = tab else { return nil }

        if let webView = webView,
           let title = webView.title,
           let url = webView.url
        {
            return WebpageMetadata(title: title, url: url)

        } else if let current = tab.current,
                  let url = current.url
        {
            return WebpageMetadata(title: current.title, url: url)

        } else if let url = tab.initialURL {
            return WebpageMetadata(title: "", url: url)
        }

        return nil
    }

    func webView(_: WKWebView, contextMenuConfigurationFor elementInfo: WKContextMenuElementInfo) async -> UIContextMenuConfiguration? {
        guard let linkURL = elementInfo.linkURL else {
            return nil
        }

        linkLongPressGestureRecognizer.pressingLinkURL = linkURL

        return UIContextMenuConfiguration()
    }

    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        logger.debug("\(navigationAction.request.httpMethod ?? "<nil method>") \(navigationAction.request.url?.absoluteString ?? "<nil url>")")

        guard let url = navigationAction.request.url else {
            return .allow
        }

        let internalURL = InternalURL(url: url)

        if case .home = internalURL {
            showNewTabVC()
        } else {
            hideNewTabVCIfNeeded()
        }

        if let scheme = url.scheme, webViewManager.handlesURLScheme(scheme) {
            return .allowWithoutTryingAppLink

        } else {
            confirmOpenExternalApp(url: url)
            return .cancel
        }
    }

    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        stickyInteraction?.showStickyBars(animated: true)

        delegate?.tabVCDidStartLoading(self)

        stickyInteraction?.update(isInteractive: false)
    }

    func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
        delegate?.tabVCDidFinishLoading(self)
    }

    func webView(_ webView: WKWebView, didCommit _: WKNavigation!) {
        guard let tab = tab else { return }

        try! tab.realm!.write {
            tab.updateBackForwardList(wkBackForwardList: webView.backForwardList)
        }

        delegate?.tabVCDidFinishLoading(self)

        screenshotManager.updateScreenshot(sources: [tab], webView: webView)
    }

    func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        delegate?.tabVCDidFinishLoading(self)
    }

    func webView(_ webView: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
        // Requested new window.
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }

        return nil
    }

    private func confirmOpenExternalApp(url: URL) {
        let title = String(format: NSLocalizedString("Open the \"%@:\" link in an external app?", comment: ""), url.scheme ?? "")

        let alert = UIAlertController(
            title: title,
            message: url.absoluteString.removingPercentEncoding,
            preferredStyle: .alert
        )

        let open = UIAlertAction(title: NSLocalizedString("Open", comment: ""), style: .default) { _ in
            UIApplication.shared.open(url)
        }
        alert.addAction(open)
        alert.preferredAction = open

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Copy", comment: ""), style: .default) { _ in UIPasteboard.general.url = url
        })

        present(alert, animated: true)
    }

    private var newTabVC: NewTabViewController?

    var addressBarContentConfiguration: AddressBar.ContentConfiguration? {
        guard let webView,
              let url = webView.url
        else { return nil }

        var content = AddressBar.ContentConfiguration()
        content.url = url
        content.isSecure = webView.hasOnlySecureContent
        return content
    }

    private func addressDidChange() {
        delegate?.tabVCDidChangeAddressBarContent(self)
    }

    private func titleOrURLDidChange() {
        guard let tab, let webView else { return }

        try! tab.realm!.write {
            tab.updateCurrentTitleOrURL(webView: webView)
        }
    }

    // MARK: - New Tab VC

    private func showNewTabVC() {
        guard let webView = webView, newTabVC == nil else {
            return
        }

        let newTabVC = NewTabViewController(
            delegate: self,
            allowsForwardGesture: webView.canGoForward,
            dependency: dependency
        )
        self.newTabVC = newTabVC

        addChild(newTabVC)
        view.addSubview(newTabVC.view)
        newTabVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        newTabVC.didMove(toParent: self)

        if webView.canGoForward {
            newTabVC.view.alpha = 0

            UIView.animate(withDuration: 0.1) {
                newTabVC.view.alpha = 1
            }
        }
    }

    private func hideNewTabVCIfNeeded() {
        guard let newTabVC = newTabVC else { return }

        self.newTabVC = nil

        newTabVC.willMove(toParent: nil)
        newTabVC.viewIfLoaded?.removeFromSuperview()
        newTabVC.removeFromParent()
    }

    func newTabVC(_: NewTabViewController, openBookmark bookmark: BookmarkItem) {
        guard let webView = webView,
              let url = bookmark.url
        else { return }

        webView.load(URLRequest(url: url))
    }

    func newTabVCForwardGestureDidRecognize(_ newTabVC: NewTabViewController) {
        webView?.goForward()

        UIView.animate(withDuration: 0.1) {
            newTabVC.view.alpha = 0
        }
    }

    // MARK: - Address edit

    func addressEditVC(_: AddressEditViewController, didEnter text: String) {
        dismiss(animated: true)

        if let url = buildSearchURL(text: text) {
            webView?.load(URLRequest(url: url))
        }
    }

    // MARK: - Edit Menu

    override func buildMenu(with builder: UIMenuBuilder) {
        let menu = UIMenu(identifier: .nfl_custom, options: .displayInline, children: [
            UIAction(title: NSLocalizedString("Search Web", comment: ""), handler: { [weak self] _ in
                self?.searchSelectedText()
            }),
        ])

        builder.insertSibling(menu, afterMenu: .standardEdit)
    }

    private func searchSelectedText() {
        webView!.evaluateJavaScript("document.getSelection().toString();") { string, _ in
            if let string = string as? String, !string.isEmpty {
                self.delegate?.tabVC(self, searchWeb: string)
            }
        }
    }

    func performCustomAction(type actionType: CustomActionType, sender: Any?) {
        switch actionType {
        case let .script(id, title, script):
            let world = WKContentWorld.world(name: id)
            webView?.evaluateJavaScript(script, in: nil, in: world) { result in
                print("custom script '\(title)' result:", result)
            }
        }
    }
}

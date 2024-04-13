import Bookmark
import Combine
import Database
import Foundation
import MenuSheet
import RealmSwift
import ThemeSystem
import UIKit
import Utils
import WebKit
import WebViewStickyInteraction

public typealias TabViewControllerDependency = UsesWebViewManager & UsesScreenshotManager & NewTabViewControllerDependency

public protocol TabViewControllerDelegate: AnyObject {
    func tabVC(_ tabVC: TabViewController, searchWeb text: String)

    func tabVC(_ tabVC: TabViewController, willShowNewTabVC newTabVC: NewTabViewController)

    func tabVCDidLongPressAddressBar(_ tabVC: TabViewController)

    func open(tab: Tab, from tabVC: TabViewController)
}

public class TabViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, NewTabViewControllerDelegate, AddressEditViewControllerDelegate {
    private let dependency: TabViewControllerDependency

    private let webViewManager: WebViewManager

    private let screenshotManager: ScreenshotManager

    public var tab: Tab? {
        didSet {
            tabDidSet()
        }
    }

    private var tabToken: NotificationToken?

    public weak var delegate: TabViewControllerDelegate?

    private var rootView: RootView!

    public var stickyBar: UIView { omnibar }

    private lazy var omnibar: Omnibar = {
        let omnibar = Omnibar(frame: .init(x: 0, y: 0, width: 300, height: Omnibar.defaultHeight))

        omnibar.addressBar.contentConfiguration = addressBarContentConfiguration

        omnibar.addressBar.addressButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(addressButtonDidLogPress(_:))))

        omnibar.progressBar.progressProvider = { [weak self] in
            self?.webView?.estimatedProgress ?? 0
        }

        omnibar.addressBar.addressButton.addAction(.init { [weak self] action in
            self?.editAddress(action.sender)
        }, for: .touchUpInside)

        let shareAction = UIAction(image: UIImage(systemName: "square.and.arrow.up")) { [weak self] action in
            self?.share(action.sender)
        }
        omnibar.addressBar.rightAccessoryView.addArrangedSubview(AddressBar.makeAccessoryButton(primaryAction: shareAction))

        return omnibar
    }()

    @objc private func addressButtonDidLogPress(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }

        delegate?.tabVCDidLongPressAddressBar(self)
    }

    public func setOmnibarButtons(left: UIButton?, right: UIButton?) {
        omnibar.setButtons(left: left, right: right)
    }

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

        let newTab = Tab(initialURL: linkURL)
        delegate?.open(tab: newTab, from: self)
    }

    private let canGoBackSubject = CurrentValueSubject<Bool, Never>(false)

    public var canGoBackPublisher: AnyPublisher<Bool, Never> {
        return canGoBackSubject.eraseToAnyPublisher()
    }

    public var canGoBack: Bool { canGoBackSubject.value }

    private let canGoForwardSubject = CurrentValueSubject<Bool, Never>(false)

    public var canGoForwardPublisher: AnyPublisher<Bool, Never> {
        return canGoForwardSubject.eraseToAnyPublisher()
    }

    public var canGoForward: Bool {
        return canGoForwardSubject.value
    }

    private var stickyBottomBar: ContainerStickyView? {
        didSet {
            stickyInteraction?.bottomView = stickyBottomBar
            stickyInteraction?.updateLayout(animated: false)
        }
    }

    public var isLoading: Bool { webView?.isLoading ?? false }

    private lazy var dialogPresenter = WebViewDialogPresenter(viewController: self)

    public init(
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

    override public func loadView() {
        let rootView = RootView(frame: UIScreen.main.bounds)
        self.rootView = rootView
        view = rootView

        rootView.addGestureRecognizer(linkLongPressGestureRecognizer)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Show newTabVC if needed

        Task { @MainActor in
            let webView = await webViewManager.getWebView(frame: view.bounds)
            self.webView = webView
            webViewContainerController.view = webView

            addChild(webViewContainerController)

            let stickyInteraction = WebViewStickyInteraction(
                topView: nil,
                bottomView: stickyBottomBar,
                allowsOverwriteScrollViewDelegate: true
            )
            self.stickyInteraction = stickyInteraction

            webView.addInteraction(stickyInteraction)
            webView.nfl_setCSSSafeAreaInsets(.zero)

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

//            webView.nfl_stickyInsets = webView.safeAreaInsets

            webViewContainerController.didMove(toParent: self)
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        webViewContainerController.additionalSafeAreaInsets.top = rootView.addressBar.frame.height
    }

    override public func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        stickyInteraction?.updateLayout(animated: false)
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

    func translate(_ sender: Any?) {
        guard let webView, let url = webView.url else { return }

        let locale = Locale.current
        let lang = locale.language.minimalIdentifier

        let googleTranslate = GoogleTranslateURLGenerator(translationLanguage: lang)

        guard let translationURL = googleTranslate.translationURL(from: url) else { return }

        webView.load(URLRequest(url: translationURL))
    }

    func openHatenaBookmark(_ sender: Any?) {
        guard let webView, let url = webView.url else { return }

        guard let entryURL = HatenaBookmarkURLGenerator().entryURL(of: url) else { return }

        webView.load(URLRequest(url: entryURL))
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

    public func tabDidActivate(stickyBottomBar: ContainerStickyView) {
        self.stickyBottomBar = stickyBottomBar
    }

    // MARK: -

    public var webpageMetadata: WebpageMetadata? {
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

    public func webView(_: WKWebView, contextMenuConfigurationFor elementInfo: WKContextMenuElementInfo) async -> UIContextMenuConfiguration? {
        guard let linkURL = elementInfo.linkURL else {
            return nil
        }

        linkLongPressGestureRecognizer.pressingLinkURL = linkURL

        return UIContextMenuConfiguration()
    }

    public func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
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
            dialogPresenter.confirmOpenExternalApp(url: url)
            return .cancel
        }
    }

    public func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        stickyInteraction?.setStickyViewsHidden(false, animated: true)

        omnibar.progressBar.start()

        stickyInteraction?.updateLayout(animated: false)
    }

    public func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
        omnibar.progressBar.finish()
    }

    public func webView(_ webView: WKWebView, didCommit _: WKNavigation!) {
        guard let tab = tab else { return }

        try! tab.realm!.write {
            tab.updateBackForwardList(wkBackForwardList: webView.backForwardList)
        }

        omnibar.progressBar.finish()

        screenshotManager.updateScreenshot(sources: [tab], webView: webView)
    }

    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        omnibar.progressBar.finish()
    }

    public func webView(_ webView: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
        // Requested new window.
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }

        return nil
    }

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        dialogPresenter.webView(webView, runJavaScriptAlertPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler)
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        dialogPresenter.webView(webView, runJavaScriptConfirmPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler)
    }

    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        dialogPresenter.webView(webView, runJavaScriptTextInputPanelWithPrompt: prompt, defaultText: defaultText, initiatedByFrame: frame, completionHandler: completionHandler)
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
        omnibar.addressBar.contentConfiguration = addressBarContentConfiguration
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

        delegate?.tabVC(self, willShowNewTabVC: newTabVC)

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

    override public func buildMenu(with builder: UIMenuBuilder) {
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

import UIKit
import WebKit

protocol StickyView: AnyObject {
    var maximumHeight: CGFloat { get }
    var minimumHeight: CGFloat { get }
    var percentHidden: CGFloat { get set }
    var hiddenHeight: CGFloat { get }

    func layoutSuperviewIfNeeded()
}

///
/// Adjusts top/bottom bars visibility in conjunction with scrolling of the web view.
///
class WebViewStickyInteraction: NSObject, UIScrollViewDelegate {
    private(set) var topBar: StickyView?

    var bottomBar: StickyView?

    private(set) weak var webView: WKWebView?

    private var isScrollTrackkingDisabled = false

    private var isScrollingToTop = false

    /// An offset top when showStickyBars(animated:) is called.
    ///
    /// It must be adjusted by adjustedContentInset.
    private var offsetTopBase: CGFloat = 0

    init(
        webView: WKWebView,
        topBar: StickyContainerView?,
        bottomBar: StickyContainerView? = nil
    ) {
        self.webView = webView
        self.topBar = topBar
        self.bottomBar = bottomBar

        webView.scrollView.automaticallyAdjustsScrollIndicatorInsets = false

        super.init()

        update(isInteractive: false)
    }

    func update(isInteractive: Bool) {
        guard let webView = webView else {
            return
        }

        if topBar == nil && bottomBar == nil {
            return
        }

        let topBarMaxHeight = topBar?.maximumHeight ?? 0
        let bottomBarMaxHeight = bottomBar?.maximumHeight ?? 0

        let scrollView = webView.scrollView
        let maxBarHeight = max(topBarMaxHeight, bottomBarMaxHeight)
        let offsetTop = scrollView.adjustedContentInset.top + scrollView.contentOffset.y

        let offsetBottom = scrollView.contentSize.height - scrollView.bounds.height - scrollView.contentOffset.y + scrollView.adjustedContentInset.bottom
        let isReachedBottom = offsetBottom < bottomBarMaxHeight

        var percentHidden: CGFloat = 0
        var stickyInsets = webView.safeAreaInsets

//        print("""
//        {
//          offsetY      = \(Int(scrollView.contentOffset.y))
//          offsetY(adj) = \(Int(scrollView.adjustedContentInset.top + scrollView.contentOffset.y))
//          adjustedContentInset = {
//            top = \(Int(scrollView.adjustedContentInset.top))
//            bottom = \(Int(scrollView.adjustedContentInset.bottom))
//          }
//          bounds.height      = \(Int(scrollView.bounds.height))
//          contentSize.height = \(Int(scrollView.contentSize.height))
//          bottomOffset = \(Int(scrollView.contentSize.height - scrollView.bounds.height - scrollView.contentOffset.y + scrollView.adjustedContentInset.bottom))
//          forceShownOffsetY = \(forceShownOffsetY.map { "\(Int($0))" } ?? "<nil>")
//        }
//        """)

        if isReachedBottom {
            if bottomBarMaxHeight > 0 {
                percentHidden = max(0, min(offsetBottom / bottomBarMaxHeight, 1))
            }

        } else {
            let maxHiddenHeight = max(0, min(offsetTop - offsetTopBase, maxBarHeight))
            percentHidden = maxHiddenHeight / maxBarHeight
        }

        topBar?.percentHidden = percentHidden
        stickyInsets.top -= topBar?.hiddenHeight ?? 0

        bottomBar?.percentHidden = percentHidden
        stickyInsets.bottom -= bottomBar?.hiddenHeight ?? 0

//        webView.nfl_stickyInsets = stickyInsets

        if isReachedBottom {
            offsetTopBase = 0

        } else if percentHidden <= 0 {
            // Fully visible
            if offsetTop > 0 {
                offsetTopBase = offsetTop

            } else {
                // Reset when the top is reached.
                offsetTopBase = 0
            }

        } else if percentHidden >= 1 {
            // Fully hidden
            offsetTopBase = 0
        }

        if isInteractive {
            webView.scrollView.verticalScrollIndicatorInsets = stickyInsets
            webView.scrollView.horizontalScrollIndicatorInsets = stickyInsets
        } else {
            UIView.animate(withDuration: 0.2) {
                webView.scrollView.verticalScrollIndicatorInsets = stickyInsets
            }
        }
    }

    func showStickyBars(animated: Bool) {
        guard let scrollView = webView?.scrollView else {
            offsetTopBase = 0
            return
        }

        offsetTopBase = scrollView.adjustedContentInset.top + scrollView.contentOffset.y

        // Disable tracking while animation.
        isScrollTrackkingDisabled = true

        update(isInteractive: animated)

        UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
            self.topBar?.layoutSuperviewIfNeeded()
            self.bottomBar?.layoutSuperviewIfNeeded()

        }, completion: { _ in
            self.isScrollTrackkingDisabled = false
        })
    }

    // MARK: - Scroll view delegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isScrollTrackkingDisabled {
            return
        } else if !scrollView.isDragging, !scrollView.isDecelerating, !isScrollingToTop {
            // Skip if set contentOffset directly.
            return
        }

        update(isInteractive: true)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            let dy = scrollView.panGestureRecognizer.translation(in: nil).y

            if dy > 0 {
                // Scroll up -> Show address bar
                showStickyBars(animated: true)
            }
        } else {
            update(isInteractive: true)
        }
    }

    func scrollViewDidEndDecelerating(_: UIScrollView) {
        if isScrollTrackkingDisabled { return }

        update(isInteractive: true)
    }

    func scrollViewShouldScrollToTop(_: UIScrollView) -> Bool {
        isScrollingToTop = true
        return true
    }

    func scrollViewDidScrollToTop(_: UIScrollView) {
        isScrollingToTop = false
    }
}

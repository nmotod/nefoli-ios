import UIKit
import WebKit

///
/// Adjusts top/bottom sticky views visibility in conjunction with scrolling of the web view.
///
public class WebViewStickyInteraction: NSObject, UIInteraction, UIScrollViewDelegate {
    public weak var view: UIView? { webView }

    public private(set) weak var webView: WKWebView?

    public var topView: StickyViewProtocol?

    public var bottomView: StickyViewProtocol?

    public let allowsOverwriteScrollViewDelegate: Bool

    public var snappingThreshold: CGFloat = 30

    public var isDebugLogEnabled = false

    private var isScrollTrackkingDisabled = false

    private var isScrollingToTop = false

    /// An offset top when showStickyViews(animated:) is called.
    ///
    /// It must be adjusted by adjustedContentInset.
    private var offsetTopBase: CGFloat = 0

    private var currentPercentHidden: CGFloat = 0

    public init(
        topView: StickyViewProtocol? = nil,
        bottomView: StickyViewProtocol? = nil,
        allowsOverwriteScrollViewDelegate: Bool
    ) {
        self.topView = topView
        self.bottomView = bottomView
        self.allowsOverwriteScrollViewDelegate = allowsOverwriteScrollViewDelegate

        super.init()

        updateLayout(animated: false)
    }

    public func willMove(to view: UIView?) {
        if view == nil {
            webView = nil
        }
    }

    public func didMove(to view: UIView?) {
        guard let view else { return }

        guard let webView = view as? WKWebView else {
            fatalError("only supports WKWebView")
        }

        self.webView = webView

        webView.scrollView.automaticallyAdjustsScrollIndicatorInsets = false

        if allowsOverwriteScrollViewDelegate {
            webView.scrollView.delegate = self
        }
    }

    public func updateLayout(animated: Bool) {
        guard let webView else {
            return
        }

        if topView == nil && bottomView == nil {
            return
        }

        let topViewMaxHeight = topView?.maxHeight ?? 0
        let bottomViewMaxHeight = bottomView?.maxHeight ?? 0

        let scrollView = webView.scrollView
        let viewsMaxHeight = max(topViewMaxHeight, bottomViewMaxHeight)
        let offsetTop = scrollView.contentInset.top + scrollView.contentOffset.y

        let offsetBottom = scrollView.contentSize.height - scrollView.bounds.height - scrollView.contentOffset.y + scrollView.contentInset.bottom
        let isReachedBottom = offsetBottom < bottomViewMaxHeight

        var percentHidden: CGFloat = 0

        if isReachedBottom {
            if bottomViewMaxHeight > 0 {
                percentHidden = max(0, min(offsetBottom / bottomViewMaxHeight, 1))
            }

        } else {
            let maxHiddenHeight = max(0, min(offsetTop - offsetTopBase, viewsMaxHeight))
            percentHidden = maxHiddenHeight / viewsMaxHeight
        }

        setPercentHidden(percentHidden, animated: animated, isReachedBottom: isReachedBottom)
    }

    private func setPercentHidden(_ percentHidden: CGFloat, animated: Bool, isReachedBottom: Bool = false) {
        currentPercentHidden = percentHidden

        guard let webView else { return }
        let scrollView = webView.scrollView

        let offsetTop = scrollView.contentInset.top + scrollView.contentOffset.y

        topView?.currentPercentHidden = percentHidden
        bottomView?.currentPercentHidden = percentHidden

        var stickyInsets = webView.safeAreaInsets
        stickyInsets.top -= topView?.currentHiddenHeight ?? 0
        stickyInsets.bottom -= bottomView?.currentHiddenHeight ?? 0

        webView.nfl_setStickyInsets(stickyInsets)

        if isDebugLogEnabled {
            print("""
            {
              percentHidden = \(String(format: "%.02f", percentHidden))
              offsetY      = \(Int(scrollView.contentOffset.y))
              offsetY(adj) = \(Int(scrollView.contentInset.top + scrollView.contentOffset.y))
              contentInset = {
                top = \(Int(scrollView.contentInset.top))
                bottom = \(Int(scrollView.contentInset.bottom))
              }
              stickyInset = {
                top = \(Int(stickyInsets.top))
                bottom = \(Int(stickyInsets.bottom))
              }
              bounds.height      = \(Int(scrollView.bounds.height))
              contentSize.height = \(Int(scrollView.contentSize.height))
              bottomOffset = \(Int(scrollView.contentSize.height - scrollView.bounds.height - scrollView.contentOffset.y + scrollView.contentInset.bottom))
              offsetTopBase = \(Int(offsetTopBase))
            }
            """)
        }

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

        if animated {
            UIView.animate(withDuration: 0.2) {
                webView.scrollView.verticalScrollIndicatorInsets = stickyInsets
                webView.scrollView.horizontalScrollIndicatorInsets = stickyInsets
            }
        } else {
            webView.scrollView.verticalScrollIndicatorInsets = stickyInsets
            webView.scrollView.horizontalScrollIndicatorInsets = stickyInsets
        }
    }

    public func setStickyViewsHidden(_ isHidden: Bool, animated: Bool) {
        if animated {
            // Disable tracking while animation.
            isScrollTrackkingDisabled = true
        }

        setPercentHidden(isHidden ? 1 : 0, animated: animated)

        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.topView?.superview?.layoutIfNeeded()
                self.bottomView?.superview?.layoutIfNeeded()

            }, completion: { _ in
                self.isScrollTrackkingDisabled = false
            })
        }
    }

    private func scrollDidStop() {
        if currentPercentHidden < 0.5 {
            setStickyViewsHidden(false, animated: true)

        } else {
            setStickyViewsHidden(true, animated: true)
        }
    }

    // MARK: - Scroll view delegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isScrollTrackkingDisabled {
            return
        } else if !scrollView.isDragging, !scrollView.isDecelerating, !isScrollingToTop {
            // Skip if set contentOffset directly.
            return
        }

        updateLayout(animated: false)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            let dy = scrollView.panGestureRecognizer.translation(in: nil).y

            if dy > 0 {
                // Scroll up -> Show sticky views
                setStickyViewsHidden(false, animated: true)
            }
        } else {
            scrollDidStop()
        }
    }

    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        if isScrollTrackkingDisabled { return }

        scrollDidStop()
    }

    public func scrollViewShouldScrollToTop(_: UIScrollView) -> Bool {
        isScrollingToTop = true
        return true
    }

    public func scrollViewDidScrollToTop(_: UIScrollView) {
        isScrollingToTop = false
    }
}

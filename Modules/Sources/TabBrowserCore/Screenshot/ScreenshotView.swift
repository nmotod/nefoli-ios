import UIKit
import Utils

public class ScreenshotView: UIView {
    public typealias Dependency = UsesScreenshotManager

    private let screenshotManager: ScreenshotManager

    private var screenshotToken: Any?

    @IBInspectable public var scale: CGFloat = 1.3

    public var source: ScreenshotSource? {
        didSet {
            guard let source = source else {
                contentView = nil
                return
            }

            contentView = screenshotManager.getContentView(source: source)
        }
    }

    private var contentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()

            if let screenshotView = contentView {
                addSubview(screenshotView)
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }

    public init(frame: CGRect, dependency: Dependency) {
        screenshotManager = dependency.screenshotManager

        super.init(frame: frame)

        clipsToBounds = true
        backgroundColor = .white
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil {
            screenshotToken = screenshotManager.observeUpdate { [weak self] key, view in
                if key == self?.source?.screenshotKey {
                    self?.contentView = view
                }
            }

        } else {
            screenshotToken = nil
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let imageView = contentView as? UIImageView,
           let image = imageView.image
        {
            let actualSize = image.size

            let width = bounds.width * scale

            imageView.frame = CGRect(
                x: 0,
                y: 0,
                width: width,
                height: actualSize.height / actualSize.width * width
            )

        } else {
            contentView?.frame = bounds
        }
    }
}

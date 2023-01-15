import UIKit

class WebLinkLongPressGestureRecognizer: UIGestureRecognizer {
    /// Longer than `UILongPressGestureRecognizer` (0.5 sec)
    let minimumPressDuration: TimeInterval = 0.7

    /// See `UILongPressGestureRecognizer.allowableMovement`
    let allowableMovement: CGFloat = 10

    var pressingLinkURL: URL?

    private var squaredTotalMovement: CGFloat = 0

    override func canBePrevented(by _: UIGestureRecognizer) -> Bool {
        return false
    }

    override func canPrevent(_: UIGestureRecognizer) -> Bool {
        return false
    }

    private weak var longPressTimer: Timer? {
        willSet {
            longPressTimer?.invalidate()
        }
    }
    
    typealias Handler = (WebLinkLongPressGestureRecognizer) -> Void
    
    let handler: Handler
    
    init(handler: @escaping Handler) {
        self.handler = handler
        
        super.init(target: nil, action: nil)
        
        addTarget(self, action: #selector(didRecognize(_:)))
    }
    
    @objc private func didRecognize(_: Any) {
        handler(self)
    }

    deinit {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }

    @objc private func didPassMinimumDuration() {
        longPressTimer = nil

        if state == .possible, pressingLinkURL != nil {
            state = .began
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        state = .possible

        let timer = Timer.scheduledTimer(timeInterval: minimumPressDuration, target: self, selector: #selector(didPassMinimumDuration), userInfo: nil, repeats: false)
        longPressTimer = timer
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        guard let touch = touches.first else {
            state = .failed
            return
        }

        let previous = touch.previousLocation(in: nil)
        let current = touch.location(in: nil)
        let dx = current.x - previous.x
        let dy = current.y - previous.y

        // movement = sqrt(dx^2 + dy^2)
        squaredTotalMovement = dx * dx + dy * dy

        if squaredTotalMovement > allowableMovement * allowableMovement {
            state = .failed
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)

        if state == .began || state == .changed {
            if pressingLinkURL != nil {
                state = .ended
                return
            }
        }

        state = .failed
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)

        state = .cancelled
    }

    override func reset() {
        super.reset()

        longPressTimer?.invalidate()
        longPressTimer = nil

        pressingLinkURL = nil
    }
}

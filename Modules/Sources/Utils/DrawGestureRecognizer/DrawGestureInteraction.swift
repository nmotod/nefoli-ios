import Foundation
import UIKit

public class DrawGestureInteraction: NSObject, UIInteraction {
    public private(set) var view: UIView?

    let recognizer = DrawGestureRecognizer()

    let indicatorView: DrawGestureIndicatorView

    public var gestures: [DrawGesture] {
        get { recognizer.gestures }
        set(newValue) { recognizer.gestures = newValue }
    }

    public init(gestures: [DrawGesture] = []) {
        indicatorView = .init(recognizer: recognizer)

        super.init()

        recognizer.addTarget(self, action: #selector(didRecognize))

        self.gestures = gestures
    }

    public func willMove(to view: UIView?) {
        if let oldView = self.view {
            self.view = nil
            oldView.removeGestureRecognizer(recognizer)
            indicatorView.removeFromSuperview()
        }
    }

    public func didMove(to view: UIView?) {
        self.view = view

        if let view {
            view.addGestureRecognizer(recognizer)
            view.window?.addSubview(indicatorView)
        }
    }

    @objc private func didRecognize() {
        switch recognizer.state {
        case .began, .changed:
            let recognizedGesture = recognizer.recognizedGesture
            let oldRecognizedGesture = indicatorView.recognizedGesture

            if recognizedGesture !== oldRecognizedGesture {
                indicatorView.recognizedGesture = recognizedGesture

                if oldRecognizedGesture == nil {
                    if recognizedGesture != nil {
                        showIndicatroView()
                    }

                } else {
                    if recognizedGesture == nil {
                        hideIndicatorView()
                    }
                }
            }

        case .ended:
            hideIndicatorView(delay: 0.1)

        case .failed, .cancelled:
            hideIndicatorView()

        default:
            break
        }
    }

    private func showIndicatroView() {
        guard let view else { return }

        view.window?.addSubview(indicatorView)
        indicatorView.isHidden = false
    }

    private func hideIndicatorView(delay: TimeInterval = 0) {
        UIView.animate(withDuration: 0.2, delay: delay, options: [.curveEaseInOut], animations: {
            self.indicatorView.alpha = 0

        }, completion: { _ in
            self.indicatorView.removeFromSuperview()
            self.indicatorView.alpha = 1
            self.indicatorView.isHidden = true
            self.indicatorView.recognizedGesture = nil
        })
    }
}

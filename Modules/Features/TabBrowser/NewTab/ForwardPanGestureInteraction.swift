import Foundation
import ThemeSystem
import UIKit
import Utils

class ForwardPanGestureInteraction: NSObject, UIInteraction {
    typealias Handler = (ForwardPanGestureInteraction) -> Void

    weak var view: UIView?

    weak var contentView: UIView?

    let onRecognizeHandler: Handler

    private let destinationPlaceholderView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.formFieldBackground.color
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 10
        return view
    }()

    private var progress: CGFloat = 0 {
        didSet {
            let progress = max(0, min(progress, 1))
            self.progress = progress

            guard let view = view else { return }

            if progress > 0 {
                destinationPlaceholderView.isHidden = false
            }

            contentView?.transform = .init(translationX: -progress * 0.5 * view.bounds.width, y: 0)
            destinationPlaceholderView.transform = .init(translationX: -progress * view.bounds.width, y: 0)

            destinationPlaceholderView.layer.shadowOpacity = Float(progress * 0.2)
        }
    }

    private let recognizer = UIScreenEdgePanGestureRecognizer()

    init(contentView: UIView, onRecognizeHandler: @escaping Handler) {
        self.contentView = contentView
        self.onRecognizeHandler = onRecognizeHandler

        super.init()

        recognizer.edges = .right
        recognizer.addTarget(self, action: #selector(didRecognize(_:)))
    }

    func willMove(to view: UIView?) {}

    func didMove(to view: UIView?) {
        self.view = view

        recognizer.view?.removeGestureRecognizer(recognizer)
        destinationPlaceholderView.removeFromSuperview()

        guard let view = view else { return }

        view.addGestureRecognizer(recognizer)

        view.addSubview(destinationPlaceholderView)
        destinationPlaceholderView.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.top.equalToSuperview()
            make.left.equalTo(view.snp.right)
        }
    }

    @objc private func didRecognize(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        guard let view = view else { return }

        switch recognizer.state {
        case .possible, .began: ()

        case .changed:
            let tx = recognizer.translation(in: nil).x

            if tx <= 0 {
                progress = -tx / view.bounds.width
            }

        case .ended:
            let vx = recognizer.velocity(in: nil).x

            if vx <= -1000 {
                complete(animationDuration: 0.2)

            } else if progress >= 0.5 {
                complete(animationDuration: SystemLikeAnimator.defaultDuration)

            } else {
                cancel()
            }

        case .failed, .cancelled:
            cancel()

        @unknown default: ()
        }
    }

    private func complete(animationDuration: TimeInterval) {
        SystemLikeAnimator.animate(withDuration: animationDuration) {
            self.progress = 1

        } completion: { _ in
            self.onRecognizeHandler(self)
        }
    }

    private func cancel() {
        SystemLikeAnimator.animate {
            self.progress = 0

        } completion: { _ in
            self.destinationPlaceholderView.isHidden = true
        }
    }
}

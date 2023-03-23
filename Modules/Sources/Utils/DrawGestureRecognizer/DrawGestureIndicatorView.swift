import UIKit

public class DrawGestureIndicatorView: UIVisualEffectView {
    private let size: CGFloat = 160

    private var stateLabel = UILabel()

    var recognizedGesture: DrawGesture? {
        didSet {
            let newValue = recognizedGesture

            if newValue === oldValue {
                return
            }

            stateLabel.text = recognizedGesture?.title ?? ""

            if oldValue == nil {
                if newValue != nil {
                    show()
                }
            } else {
                if newValue == nil {
                    hide()
                }
            }
        }
    }

    let drawGestureRecognizer: DrawGestureRecognizer

    public init(recognizer: DrawGestureRecognizer) {
        drawGestureRecognizer = recognizer

        super.init(effect: UIBlurEffect(style: .systemMaterialDark))
        setup()

        recognizer.addTarget(self, action: #selector(didRecognize(_:)))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setup() {
        layer.masksToBounds = true
        layer.cornerRadius = 10
        backgroundColor = .clear

        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),
        ])

        stateLabel.font = UIFont.systemFont(ofSize: 20)
        stateLabel.textColor = .lightText
        stateLabel.textAlignment = .center
        stateLabel.text = "(state)"
        contentView.addSubview(stateLabel)

        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            stateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ])
    }

    @objc func didRecognize(_ recognizer: DrawGestureRecognizer) {
        recognizedGesture = recognizer.recognizedGesture

        switch recognizer.state {
        case .ended:
            hide(delay: 0.1)

        case .failed: fallthrough
        case .cancelled:
            hide()

        default:
            break
        }
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard let superview = superview else { return }

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor),
        ])

        isHidden = true
    }

    func show() {
        alpha = 1
        isHidden = false
    }

    func hide(delay: TimeInterval = 0) {
        UIView.animate(withDuration: 0.2, delay: delay, options: [.curveEaseInOut], animations: {
            self.alpha = 0

        }, completion: { _ in
            self.isHidden = true
            self.recognizedGesture = nil
        })
    }
}

#if DEBUG
import SwiftUI

private struct Wrapper: UIViewRepresentable {
    typealias UIViewType = DrawGestureIndicatorView

    func makeUIView(context _: Context) -> DrawGestureIndicatorView {
        return DrawGestureIndicatorView(recognizer: DrawGestureRecognizer())
    }

    func updateUIView(_ uiView: DrawGestureIndicatorView, context _: Context) {
        uiView.recognizedGesture = DrawGesture(strokeDirections: [], title: "Gesture Recognized", handler: nil)
    }
}

struct DrawGestureIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Wrapper()
        }
    }
}
#endif

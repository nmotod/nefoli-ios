import SnapKit
import UIKit

public class DrawGestureIndicatorView: UIVisualEffectView {
    private var stateLabel = UILabel()

    var recognizedGesture: DrawGesture? {
        didSet {
            let newValue = recognizedGesture

            if newValue === oldValue {
                return
            }

            stateLabel.text = recognizedGesture?.title ?? ""
        }
    }

    public init(recognizer: DrawGestureRecognizer) {
        super.init(effect: UIBlurEffect(style: .systemChromeMaterialDark))
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setup() {
        layer.masksToBounds = true
        layer.cornerRadius = 10
        backgroundColor = .clear

        stateLabel.font = UIFont.systemFont(ofSize: 30)
        stateLabel.textColor = .white
        stateLabel.text = "(state)"
        contentView.addSubview(stateLabel)

        stateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
        }
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard superview != nil else { return }

        snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
        }

        isHidden = true
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

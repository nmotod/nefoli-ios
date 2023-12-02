import SnapKit
import ThemeSystem
import UIKit

class ProgressBar: UIView {
    typealias ProgressProvider = () -> Double

    private var indicatorWidthConstraint: Constraint!

    private let indicatorView = UIView()

    var progressProvider: ProgressProvider?

    var progress: Double = 0.0 {
        didSet {
            redrawIndicator()
        }
    }

    private var updatingTimer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }

    deinit {
        stopTimer()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(indicatorView)

        backgroundColor = .clear

        indicatorView.backgroundColor = ThemeColors.progressBarIndicator.color
        indicatorView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            indicatorWidthConstraint = make.width.equalTo(0).constraint
        }

        progress = 0
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if window == nil {
            stopTimer()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        redrawIndicator()
    }

    private func redrawIndicator() {
        let progress = max(0.0, min(progress, 1.0))

        var width = CGFloat(Double(bounds.width) * progress)

        if updatingTimer != nil, width < 5 {
            // Display just a little width.
            width = 5
        }

        indicatorWidthConstraint.update(offset: width)
    }

    func start() {
        if updatingTimer != nil {
            return
        }

        progress = 0

        updatingTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgressFromProvider), userInfo: nil, repeats: true)

        UIView.animate(withDuration: 0.1, animations: {
            self.indicatorView.alpha = 1
        })
    }

    private func stopTimer() {
        updatingTimer = nil
    }

    @objc private func updateProgressFromProvider() {
        progress = progressProvider?() ?? 0.0

        redrawIndicator()

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }

    func finish() {
        stopTimer()

        progress = 1.0

        UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                self.layoutIfNeeded()
            }

            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.6) {
                self.indicatorView.alpha = 0
            }
        }, completion: nil)

//        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
//            self.layoutIfNeeded()
//
//        }) { (_) in
//            UIView.animate(withDuration: 0.3, delay: 0.7, options: .curveEaseInOut, animations: {
//                self.indicatorView.alpha = 0
//            }, completion: nil)
//        }
    }
}

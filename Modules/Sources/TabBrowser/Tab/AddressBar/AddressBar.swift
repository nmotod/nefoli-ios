import Database
import RealmSwift
import Theme
import UIKit

class AddressBar: UIView {
    static let defaultHeight: CGFloat = 50

    let labelButton = AddressBarLabelButton()

    var contentOpacity: CGFloat = 1 {
        didSet {
            labelButton.alpha = contentOpacity
            reloadButton.alpha = contentOpacity
        }
    }

    var addressText: String {
        get { labelButton.addressText }
        set { labelButton.addressText = newValue }
    }

    var isSecure: Bool {
        get { labelButton.isSecure }
        set { labelButton.isSecure = newValue }
    }

    let reloadButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.buttonSize = .small
        config.image = UIImage(systemName: "arrow.clockwise")
        config.contentInsets = .init(top: 0, leading: 0, bottom: 4, trailing: 10)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.tintColor = Colors.tint.color
        return button
    }()

    /// A margin between addressBar.top and safeArea.top
    var topMarginConstraint: Constraint?

    var maxHeight: CGFloat { frame.height }

    var currentHeight: CGFloat {
        get {
            return maxHeight + marginTop
        }

        set {
            let newHeight = newValue

            marginTop = newHeight - maxHeight

            if newHeight < maxHeight {
                // Stick out to outside top.
                let visibility = newHeight / maxHeight
                contentOpacity = max(0, min(visibility, 1))
            } else {
                contentOpacity = 1
            }
        }
    }

    var marginTop: CGFloat = 0 {
        didSet {
            topMarginConstraint?.update(offset: marginTop)

            if marginTop < 0 {
                // Stick out to outside top.
                let visibility = (frame.height + marginTop) / frame.height
                contentOpacity = max(0, min(visibility, 1))
            } else {
                contentOpacity = 1
            }
        }
    }

    var tab: Tab? {
        didSet {
            if tab == oldValue {
                return
            }

            updateUI()
        }
    }

    override init(frame: CGRect = CGRect(x: 0, y: 0, width: 300, height: 50)) {
        super.init(frame: frame)

        addSubview(labelButton)
        labelButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(reloadButton)

        reloadButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(50)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func didChangeTab(_ change: ObjectChange<Tab>) {
        switch change {
        case .change:
            updateUI()

        case .deleted:
            tab = nil

        case .error: ()
        }
    }

    private func updateUI() {
        let title: String

        if let url = tab?.current?.url ?? tab?.initialURL {
            title = url.host ?? url.absoluteString
        } else {
            title = ""
        }

        addressText = title
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Self.defaultHeight)
    }
}

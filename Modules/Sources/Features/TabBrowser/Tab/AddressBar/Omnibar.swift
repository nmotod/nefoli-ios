import ActionSystem
import Foundation
import ThemeSystem
import UIKit

class Omnibar: UIStackView {
    static let defaultHeight: CGFloat = 58

    static let addressBarInnerHeight: CGFloat = 40

    static let addressBarBorderInsetY: CGFloat = (defaultHeight - addressBarInnerHeight) / 2

    let addressBar = AddressBar(
        frame: .init(x: 0, y: 0, width: 50, height: defaultHeight),
        borderInsets: .init(top: addressBarBorderInsetY, left: 0, bottom: addressBarBorderInsetY, right: 0)
    )

    let progressBar = ProgressBar()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addArrangedSubview(addressBar)

        backgroundColor = .clear

        addSubview(progressBar)
        progressBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-0.5)
            make.height.equalTo(3)
        }

        progressBar.progress = 0.5
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return .init(width: UIView.noIntrinsicMetric, height: type(of: self).defaultHeight)
    }

    func setButtons(left: UIButton?, right: UIButton?) {
        arrangedSubviews.forEach { $0.removeFromSuperview() }

        [left, addressBar, right]
            .compactMap { $0 }
            .forEach(addArrangedSubview(_:))
    }
}

#Preview("Omnibar", traits: .sizeThatFitsLayout) {
    let vStackView = UIStackView()
    vStackView.axis = .vertical
    vStackView.spacing = 5
    vStackView.snp.makeConstraints { make in
        make.width.equalTo(375)
    }

    addPreview("Empty") { omnibar in
        omnibar.addressBar.contentConfiguration = nil
    }

    addPreview("Internal URL") { omnibar in
        var content = AddressBar.ContentConfiguration()
        content.url = URL(string: "internal://internal/home")
        content.isSecure = true
        omnibar.addressBar.contentConfiguration = content
    }

    addPreview("Secure") { omnibar in
        var content = AddressBar.ContentConfiguration()
        content.url = URL(string: "https://example.com")
        content.isSecure = true
        omnibar.addressBar.contentConfiguration = content
    }

    addPreview("Insecure") { omnibar in
        var content = AddressBar.ContentConfiguration()
        content.url = URL(string: "http://example.com")
        content.isSecure = false
        omnibar.addressBar.contentConfiguration = content
    }

    addPreview("Long URL") { omnibar in
        var content = AddressBar.ContentConfiguration()
        content.url = URL(string: "https://the-long-long-long-long-long-domain-of.example.com")
        content.isSecure = true
        omnibar.addressBar.contentConfiguration = content
    }

    return vStackView

    func makeButton(actionType: any ActionTypeProtocol) -> UIButton {
        let button = UIButton(primaryAction: UIAction(image: actionType.image) { _ in })
        button.tintColor = ThemeColors.tint.color
        button.snp.makeConstraints { make in
            make.width.equalTo(44)
        }
        return button
    }

    func addPreview(_ title: String, setup: (Omnibar) -> Void) {
        let label = UILabel()
        label.text = "\n" + title
        label.numberOfLines = -1
        vStackView.addArrangedSubview(label)

        let bgView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))

        bgView.snp.makeConstraints { make in
            make.height.equalTo(Omnibar.defaultHeight)
        }

        let omnibar = Omnibar()

        omnibar.setButtons(
            left: makeButton(actionType: TabActionType.goBack),
            right: makeButton(actionType: TabBrowserActionType.menuSheet)
        )

        bgView.contentView.addSubview(omnibar)
        omnibar.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setup(omnibar)

        vStackView.addArrangedSubview(bgView)
    }
}

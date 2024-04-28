import Foundation
import ThemeSystem
import UIKit

class AddressBar: UIView {
    struct ContentConfiguration {
        var url: URL?
        var isSecure: Bool = false

        var hasInternalURL: Bool {
            guard let url else { return false }
            return InternalURL.isInternalURL(url)
        }
    }

    static let borderCornerRadius: CGFloat = 12

    var contentConfiguration: ContentConfiguration? {
        didSet {
            updateContent()
        }
    }

    let addressButton: AddressTextButton

    let rightAccessoryView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        return view
    }()

    init(
        frame: CGRect,
        borderInsets: UIEdgeInsets
    ) {
        addressButton = AddressTextButton(frame: frame, borderInsets: borderInsets)

        super.init(frame: frame)

        addSubview(addressButton)
        addressButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(rightAccessoryView)
        rightAccessoryView.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
        }

        updateContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateContent() {
        addressButton.contentConfiguration = contentConfiguration

        if let contentConfiguration, !contentConfiguration.hasInternalURL {
            rightAccessoryView.isHidden = false
        } else {
            rightAccessoryView.isHidden = true
        }
    }
}

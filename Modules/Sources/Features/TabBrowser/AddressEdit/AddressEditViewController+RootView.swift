import Foundation
import ThemeSystem
import UIKit

protocol AddressEditViewControllerRootViewHandler: AnyObject {
    func cancel()

    func didEnterReturn()
}

extension AddressEditViewController {
    class RootView: UIView, MultilineAddressFieldDelegate {
        weak var handler: AddressEditViewControllerRootViewHandler?

        let dimmingView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(white: 0, alpha: 0.5)
            return view
        }()

        let contentView = UIView()

        let addressField = MultilineAddressField()

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 44))

        lazy var clearTextButtonItem: UIBarButtonItem = {
            let item = UIBarButtonItem(primaryAction: UIAction(
                title: NSLocalizedString("Clear", comment: ""),
                handler: { [weak self] _ in
                    self?.addressField.clearText()
                }
            ))
            return item
        }()

        lazy var cancelButtonItem: UIBarButtonItem = {
            let item = UIBarButtonItem(primaryAction: UIAction(
                title: NSLocalizedString("Cancel", comment: ""),
                handler: { [weak self] _ in
                    self?.handler?.cancel()
                }
            ))
            return item
        }()

        init(
            frame: CGRect,
            initialText: String,
            handler: AddressEditViewControllerRootViewHandler
        ) {
            self.handler = handler

            super.init(frame: frame)

            backgroundColor = .clear

            dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancel)))

            addSubview(dimmingView)
            dimmingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            contentView.backgroundColor = ThemeColors.background.color
            addSubview(contentView)
            contentView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.greaterThanOrEqualTo(safeAreaLayoutGuide.snp.top)
            }

            let appearance = UIToolbarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = nil
            appearance.backgroundColor = .clear
            appearance.shadowColor = .clear
            toolbar.standardAppearance = appearance

            toolbar.tintColor = ThemeColors.tint.color
            toolbar.items = [
                UIBarButtonItem.flexibleSpace(),
                clearTextButtonItem,
                cancelButtonItem,
            ]

            toolbar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deselectText)))

            contentView.addSubview(toolbar)
            toolbar.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(keyboardLayoutGuide.snp.top)
                make.height.equalTo(44)
            }

            addressField.delegate = self
            addressField.text = initialText

            addressField.backgroundColor = .clear
            contentView.addSubview(addressField)
            addressField.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
//                make.bottom.equalTo(contentView.keyboardLayoutGuide.snp.top)
                make.bottom.equalTo(toolbar.snp.top)
                make.height.greaterThanOrEqualTo(50)
            }

            clearTextButtonItem.isEnabled = !addressField.text.isEmpty
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Actions

        @objc private func cancel() {
            handler?.cancel()
        }

        @objc private func deselectText() {
            addressField.deselectText()
        }

        // MARK: - Multiline address field delegate

        func multilineAddressFieldDidChange(_: MultilineAddressField) {
            clearTextButtonItem.isEnabled = !addressField.text.isEmpty
        }

        func multilineAddressFieldDidReturn(_: MultilineAddressField) {
            handler?.didEnterReturn()
        }
    }
}

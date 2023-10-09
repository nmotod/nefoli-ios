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
                image: UIImage(systemName: "trash",
                               withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                handler: { [weak self] _ in
                    self?.addressField.clearText()
                }
            ))
            item.width = 44
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

            contentView.backgroundColor = UIColor(white: 0.2, alpha: 1)
            addSubview(contentView)
            contentView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.greaterThanOrEqualTo(safeAreaLayoutGuide.snp.top)
            }

            toolbar.barStyle = .black
            toolbar.tintColor = Colors.tint.color
            toolbar.items = [
                UIBarButtonItem.flexibleSpace(),
                clearTextButtonItem,
                UIBarButtonItem(primaryAction: UIAction(
                    title: NSLocalizedString("Cancel", comment: ""),
                    handler: { [weak self] _ in
                        self?.cancel()
                    }
                )),
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

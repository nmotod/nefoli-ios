import Foundation
import Theme
import UIKit

protocol AddressEditViewControllerDelegate: AnyObject {
    func addressEditVC(_: AddressEditViewController, didEnter text: String)
}

class AddressEditViewController: UIViewController, AddressEditViewControllerRootViewHandler {
    let initialText: String

    weak var delegate: AddressEditViewControllerDelegate?

    private var rootView: RootView!

    init(
        initialText: String,
        delegate: AddressEditViewControllerDelegate
    ) {
        self.initialText = initialText
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let rootView = RootView(
            frame: UIScreen.main.bounds,
            initialText: initialText,
            handler: self
        )
        self.rootView = rootView
        view = rootView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        rootView.addressField.selectAll(self)
        rootView.addressField.becomeFirstResponder()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        rootView.addressField.invalidateIntrinsicContentSize()
    }

    // MARK: - Actions

    func cancel() {
        dismiss(animated: true)
    }

    func didEnterReturn() {
        let text = rootView.addressField.text

        if !text.isEmpty {
            delegate?.addressEditVC(self, didEnter: text)
        }
    }
}

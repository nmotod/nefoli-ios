import Foundation
import NFLThemeSystem
import UIKit

protocol AddressEditViewControllerDelegate: AnyObject {
    func addressEditVC(_: AddressEditViewController, didEnter text: String)
}

class AddressEditViewController: UIViewController, AddressEditViewControllerRootViewHandler {
    let initialURL: URL?

    private var initialText: String {
        guard let initialURL,
              !InternalURL.isInternalURL(initialURL)
        else {
            return ""
        }

        return initialURL.absoluteString
    }

    weak var delegate: AddressEditViewControllerDelegate?

    private var rootView: RootView!

    init(
        initialURL: URL?,
        delegate: AddressEditViewControllerDelegate?
    ) {
        self.initialURL = initialURL
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

#Preview("AddressEdit", body: {
    return AddressEditViewController(
        initialURL: nil,
        delegate: nil
    )
})

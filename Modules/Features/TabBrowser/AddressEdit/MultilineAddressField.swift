import Foundation
import ThemeSystem
import UIKit

protocol MultilineAddressFieldDelegate: AnyObject {
    func multilineAddressFieldDidChange(_: MultilineAddressField)
    func multilineAddressFieldDidReturn(_: MultilineAddressField)
}

class MultilineAddressField: UIView, UITextViewDelegate {
    weak var delegate: MultilineAddressFieldDelegate?

    private let font = UIFont.systemFont(ofSize: 15)

    private let textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 14, right: 16)

    private let borderInsets = UIEdgeInsets(top: 10, left: 10, bottom: 4, right: 10)

    private let textView = UITextView()

    private let placeholderView = UITextView()

    private let borderLayer = CALayer()

    var text: String {
        get { textView.text }
        set {
            textView.text = newValue
            updatePlaceholderState()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        borderLayer.backgroundColor = Colors.addressBarLabelBackgroundNormal.color.cgColor
        borderLayer.cornerRadius = 12
        borderLayer.masksToBounds = true
        layer.addSublayer(borderLayer)

        textView.delegate = self

        textView.returnKeyType = .go
        textView.enablesReturnKeyAutomatically = true
        textView.keyboardType = .webSearch
        textView.keyboardAppearance = ThemeValues.keyboardAppearance

        textView.textContainer.lineBreakMode = .byCharWrapping
        textView.textContainerInset = textContainerInset

        textView.font = font
        textView.textColor = UIColor(white: 0.8, alpha: 1)
        textView.tintColor = UIColor.tintColor.resolvedColor(with: .init(userInterfaceStyle: .dark))
        textView.backgroundColor = .clear
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        placeholderView.textContainerInset = textContainerInset
        placeholderView.font = font
        placeholderView.textColor = UIColor(white: 0.6, alpha: 1)
        placeholderView.backgroundColor = .clear
        placeholderView.text = NSLocalizedString("Search or enter address", comment: "")
        placeholderView.isUserInteractionEnabled = false
        addSubview(placeholderView)
        placeholderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        updatePlaceholderState()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return textView.contentSize
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        borderLayer.frame = textView.frame.inset(by: borderInsets)
        CATransaction.commit()
    }

    // MARK: - Responder

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    override var canBecomeFirstResponder: Bool {
        return textView.canBecomeFirstResponder
    }

    // MARK: - Actions

    override func selectAll(_ sender: Any?) {
        textView.selectAll(sender)
    }

    /// Deselect text and move cursor to the end.
    func deselectText() {
        textView.selectedTextRange = textView.textRange(from: textView.endOfDocument, to: textView.endOfDocument)
    }

    func clearText() {
        text = ""

        invalidateIntrinsicContentSize()

        delegate?.multilineAddressFieldDidChange(self)
    }

    private func updatePlaceholderState() {
        placeholderView.isHidden = !text.isEmpty
    }

    // MARK: - Text view delegate

    // Hnadle only LF.
    // Somehow, [\r\n]+ does not work.
    private let newLines = try! Regex("\n+")

    func textViewDidChange(_: UITextView) {
        invalidateIntrinsicContentSize()
        updatePlaceholderState()

        delegate?.multilineAddressFieldDidChange(self)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText: String) -> Bool {
        if replacementText == "\n" {
            delegate?.multilineAddressFieldDidReturn(self)
            return false
        }

        if !replacementText.contains(newLines) {
            return true
        }

        let replacementText = replacementText.replacing(newLines, with: { _ in " " })

        let text = textView.text ?? ""
        let start = text.index(text.startIndex, offsetBy: range.location)
        let last = text.index(start, offsetBy: range.length)

        textView.text = text.replacingCharacters(in: start ..< last, with: replacementText)

        return false
    }
}

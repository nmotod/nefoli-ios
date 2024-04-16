import Combine
import UIKit
import WebKit

enum BackForwardState {
    case canGoBack
    case canOnlyGoForward
    case disabled

    init(
        canGoBack: Bool,
        canGoForward: Bool
    ) {
        if canGoBack {
            self = .canGoBack
        } else if canGoForward {
            self = .canOnlyGoForward
        } else {
            self = .disabled
        }
    }
}

class BackForwardButton: UIButton {
    var backForwardState: BackForwardState = .disabled {
        didSet {
            didUpdateState()
        }
    }

    var onGoBack: (_ sender: Any?) -> Void

    var onGoForward: (_ sender: Any?) -> Void

    var onGoTo: (WKBackForwardListItem) -> Void

    var listProvider: () -> WKBackForwardList?

    init(
        onGoBack: @escaping (_ sender: Any?) -> Void,
        onGoForward: @escaping (_ sender: Any?) -> Void,
        onGoTo: @escaping (WKBackForwardListItem) -> Void,
        listProvider: @escaping () -> WKBackForwardList?
    ) {
        self.onGoBack = onGoBack
        self.onGoForward = onGoForward
        self.onGoTo = onGoTo
        self.listProvider = listProvider

        super.init(frame: .zero)

        Omnibar.configureOmnibarButton(button: self)
        didUpdateState()

        addTarget(self, action: #selector(onClick), for: .touchUpInside)

        menu = UIMenu(children: [UIDeferredMenuElement.uncached { [weak self] completion in
            completion(self?.buildListMenuItems() ?? [])
        }])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func didUpdateState() {
        switch backForwardState {
        case .canGoBack:
            setImage(TabActionType.goBack.image, for: .normal)
            isEnabled = true
            showsMenuAsPrimaryAction = false

        case .canOnlyGoForward:
            setImage(TabActionType.goForward.image, for: .normal)
            isEnabled = true
            showsMenuAsPrimaryAction = true

        case .disabled:
            setImage(TabActionType.goBack.image, for: .normal)
            isEnabled = false
            showsMenuAsPrimaryAction = false
        }
    }

    @objc private func onClick() {
        switch backForwardState {
        case .canGoBack:
            onGoBack(self)

        case .canOnlyGoForward:
            onGoForward(self)

        case .disabled:
            break
        }
    }

    private func makeBackForwardAction(item: WKBackForwardListItem, isCurrentItem: Bool) -> UIAction {
        let action = UIAction(title: item.title ?? "", subtitle: item.url.absoluteString) { [weak self] _ in
            self?.onGoTo(item)
        }

        if isCurrentItem {
            action.attributes = .disabled
        }

        return action
    }

    private func buildListMenuItems() -> [UIMenuElement] {
        guard let backForwardList = listProvider(),
              let currentItem = backForwardList.currentItem
        else {
            return []
        }

        let items = backForwardList.backList + [currentItem] + backForwardList.forwardList

        let menuItems = items.map { item in
            self.makeBackForwardAction(item: item, isCurrentItem: item === currentItem)
        }
        return menuItems
    }
}

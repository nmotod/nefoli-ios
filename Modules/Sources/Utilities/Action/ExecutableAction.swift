import Combine
import UIKit

public class ExecutableAction: Hashable {
    public struct Context {
        public var viewController: UIViewController?
        public var uiAction: UIAction?

        public init(
            viewController: UIViewController? = nil,
            uiAction: UIAction? = nil
        ) {
            self.viewController = viewController
            self.uiAction = uiAction
        }
    }

    public typealias Handler = @MainActor (Context) -> Void

    public let action: any ActionProtocol

    public let uiAction: UIAction

    public var title: String {
        get { uiAction.title }
        set { uiAction.title = newValue }
    }

    public var subtitle: String? {
        get { uiAction.subtitle }
        set { uiAction.subtitle = newValue }
    }

    public var image: UIImage? {
        get { uiAction.image }
        set { uiAction.image = newValue }
    }

    public var identifier: UIAction.Identifier? { uiAction.identifier }

    public var discoverabilityTitle: String? {
        get { uiAction.discoverabilityTitle }
        set { uiAction.discoverabilityTitle = newValue }
    }

    public let handler: Handler

    private var _barButtonItem: UIBarButtonItem?

    public var barButtonItem: UIBarButtonItem {
        if let barButtonItem = _barButtonItem {
            return barButtonItem
        }

        let item = ActionBarButtonItem(action: self)
        _barButtonItem = item

        item.isEnabled = isEnabled
        item.width = 44

        return item
    }

    @Published public private(set) var isEnabled: Bool

    private var isEnabledCancellable: Any?

    public var userInfo: [AnyHashable: Any] = [:]

    public init(
        action: any ActionProtocol,
        title: String,
        subtitle: String? = nil,
        image: UIImage? = nil,
        discoverabilityTitle: String? = nil,
        isEnabled: Bool = true,
        isEnabledPublisher: AnyPublisher<Bool, Never>? = nil,
        handler: @escaping Handler
    ) {
        self.action = action
        self.handler = handler
        self.isEnabled = isEnabled

        weak var weakSelf: ExecutableAction?

        uiAction = UIAction(
            title: title,
            subtitle: subtitle,
            image: image,
            identifier: .init(action.identifier),
            discoverabilityTitle: discoverabilityTitle,
            handler: { uiAction in
                guard let self = weakSelf else { return }

                Task {
                    await self.handler(Context(uiAction: uiAction))
                }
            }
        )

        weakSelf = self

        if let isEnabledPublisher = isEnabledPublisher {
            isEnabledCancellable = isEnabledPublisher.sink { [weak self] isEnabled in
                self?.isEnabled = isEnabled
            }
        }
    }

    @MainActor
    public func execute(_ context: Context? = nil) {
        handler(context ?? Context())
    }

    public static func == (lhs: ExecutableAction, rhs: ExecutableAction) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension ExecutableAction {
    public convenience init<ID: ActionProtocol>(
        definition: ActionDefinition<ID>,
        isEnabled: Bool = true,
        isEnabledPublisher: AnyPublisher<Bool, Never>? = nil,
        handler: @escaping Handler
    ) {
        self.init(
            action: definition.action,
            title: definition.title,
            subtitle: definition.subtitle,
            image: definition.image,
            discoverabilityTitle: definition.discoverabilityTitle,
            isEnabled: isEnabled,
            isEnabledPublisher: isEnabledPublisher,
            handler: handler
        )
    }
}

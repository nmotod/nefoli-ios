import Foundation
import UIKit

public class ActionBarButtonItem: UIBarButtonItem {
    private let executable: ExecutableAction

    private var isEnabledCancellable: Any?

    init(action: ExecutableAction) {
        executable = action

        super.init()

        primaryAction = action.uiAction

        isEnabledCancellable = action.$isEnabled.sink { [weak self] isEnabled in
            self?.isEnabled = isEnabled
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

import CommandSystem
import Foundation
import UIKit

extension TabBrowserController {
    public class func supportedCommands() -> [any CommandProtocol] {
        return TabBrowserCommand.allCases + TabCommand.allCases
    }

    func execute(command: TabBrowserCommand, sender: Any?) {
        switch command {
        case .bookmarks:
            showBookmarks(sender)

        case .closeActiveTab:
            closeActiveTab()

        case .menuSheet:
            showMenuSheet()

        case .tabs:
            ()

        case .settings:
            showSettings(sender)

        case .restoreClosedTab:
            restoreClosedTab(sender)

        case .debugEditBookmark:
            ()
        }
    }

    public func executeAny(command: any CommandProtocol, sender: Any?) throws {
        if let command = command as? TabBrowserCommand {
            execute(command: command, sender: sender)

        } else if let command = command as? TabCommand {
            activeVC?.execute(command: command, sender: sender)

        } else if let command = command as? CustomCommand {
            activeVC?.executeCustom(command: command, sender: sender)

        } else {
            throw CommandError.unsupported
        }
    }

    func makeUIAction(for command: any CommandProtocol) -> UIAction? {
        return command.makeUIAction { [weak self] uiAction in
            guard let self else { return }

            try! self.executeAny(command: command, sender: uiAction.sender)
        }
    }
}

import CommandSystem
import Foundation
import UIKit

extension TabGroupController {
    public class func supportedCommands() -> [any CommandProtocol] {
        return TabGroupCommand.allCases + TabCommand.allCases
    }

    func execute(command: TabGroupCommand, sender: Any?) {
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
            ()

        case .debugEditBookmark:
            ()
        }
    }

    public func executeAny(command: any CommandProtocol, sender: Any?) throws {
        if let command = command as? TabGroupCommand {
            execute(command: command, sender: sender)

        } else if let command = command as? TabCommand {
            activeVC?.execute(command: command, sender: sender)

        } else {
            throw CommandError.unsupported
        }
    }

    func makeUIAction(for command: any CommandProtocol) -> UIAction? {
        if let command = command as? TabGroupCommand {
            return command.makeUIAction { [weak self] uiAction in
                guard let self else { return }

                self.execute(command: command, sender: uiAction.sender)
            }

        } else if let command = command as? TabCommand {
            return command.makeUIAction { [weak self] uiAction in
                guard let self else { return }

                self.activeVC?.execute(command: command, sender: uiAction.sender)
            }
        }

        return nil
    }
}

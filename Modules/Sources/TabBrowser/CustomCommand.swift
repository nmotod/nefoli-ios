import CommandSystem
import Foundation
import UIKit

enum CustomCommand: CommandProtocol {
    static var idPrefix = "custom"

    // TODO: store script in DB, and chnage command to just a reference
    case script(id: String, title: String, script: String)

    var definition: CommandSystem.CommandDefinition {
        switch self {
        case let .script(_, title, _):
            return CommandDefinition(
                title: title,
                image: UIImage(systemName: "play.circle")
            )
        }
    }

    var id: String {
        switch self {
        case let .script(id, _, _):
            return "\(type(of: self).idPrefix).\(id)"
        }
    }
}

private let scriptDefinition = CommandDefinition(
    title: "Script",
    image: UIImage(systemName: "play.circle")
)

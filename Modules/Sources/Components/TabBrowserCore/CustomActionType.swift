import ActionSystem
import Foundation
import UIKit

enum CustomActionType: ActionTypeProtocol {
    static var idPrefix = "custom"

    // TODO: store script in DB, and chnage action to just a reference
    case script(id: String, title: String, script: String)

    var definition: ActionTypeDefinition {
        switch self {
        case let .script(_, title, _):
            return ActionTypeDefinition(
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

private let scriptDefinition = ActionTypeDefinition(
    title: "Script",
    image: UIImage(systemName: "play.circle")
)

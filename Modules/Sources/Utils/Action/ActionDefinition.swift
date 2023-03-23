import Foundation
import UIKit

public struct ActionDefinition<Action: ActionProtocol> {
    public typealias ActionBuilder = (ActionDefinition<Action>, Action.BuilderContext) -> ExecutableAction

    public var action: Action

    public var title: String

    public var subtitle: String?

    public var image: UIImage?

    public var discoverabilityTitle: String?

    public var builder: ActionBuilder
}

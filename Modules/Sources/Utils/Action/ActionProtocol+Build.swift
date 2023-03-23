import Foundation
import UIKit

extension ActionProtocol {
    public static var definitions: [ActionDefinition<Self>] {
        return allCases.map(\.definition)
    }

    public func buildDefinition(
        title: String,
        subtitle: String? = nil,
        image: UIImage? = nil,
        discoverabilityTitle: String? = nil,
        builder: @escaping ActionDefinition<Self>.ActionBuilder
    ) -> ActionDefinition<Self> {
        return ActionDefinition(
            action: self,
            title: title,
            subtitle: subtitle,
            image: image,
            discoverabilityTitle: discoverabilityTitle,
            builder: builder
        )
    }

    public func buildExecutable(context: BuilderContext) -> ExecutableAction {
        let definition = definition

        return definition.builder(definition, context)
    }
}

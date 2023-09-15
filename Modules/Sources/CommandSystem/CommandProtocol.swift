import Foundation
import UIKit

public protocol CommandProtocol: Identifiable where ID == String {
    var definition: CommandDefinition { get }

    static var idPrefix: String { get }

    func makeUIAction(handler: @escaping UIActionHandler) -> UIAction
}

extension CommandProtocol where Self: RawRepresentable, RawValue == String {
    public var id: String {
        return "\(type(of: self).idPrefix).\(rawValue)"
    }

    public var title: String {
        return definition.title
    }

    public var subtitle: String? {
        return definition.subtitle
    }

    public var image: UIImage? {
        return definition.image
    }

    public var discoverabilityTitle: String? {
        return definition.discoverabilityTitle
    }

    public func makeUIAction(handler: @escaping UIActionHandler) -> UIAction {
        return UIAction(
            title: title,
            subtitle: subtitle,
            image: image,
            discoverabilityTitle: discoverabilityTitle,
            handler: handler
        )
    }
}

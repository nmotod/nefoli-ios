import Foundation
import UIKit

public protocol CommandProtocol: Identifiable where ID == String {
    static var idPrefix: String { get }

    var definition: CommandDefinition { get }

    var title: String { get }

    var subtitle: String? { get }

    var image: UIImage? { get }

    var discoverabilityTitle: String? { get }

    func makeUIAction(handler: @escaping UIActionHandler) -> UIAction
}

extension CommandProtocol {
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

extension CommandProtocol where Self: RawRepresentable, RawValue == String {
    public var id: String {
        return "\(type(of: self).idPrefix).\(rawValue)"
    }
}

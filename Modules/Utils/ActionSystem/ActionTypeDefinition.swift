import Foundation
import UIKit

public struct ActionTypeDefinition {
    public var title: String

    public var subtitle: String?

    public var image: UIImage?

    public var discoverabilityTitle: String?

    public init(
        title: String,
        subtitle: String? = nil,
        image: UIImage? = nil,
        discoverabilityTitle: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.discoverabilityTitle = discoverabilityTitle
    }
}

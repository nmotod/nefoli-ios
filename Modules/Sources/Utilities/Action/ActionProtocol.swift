import Foundation

public protocol ActionProtocol: RawRepresentable<String>, Hashable, CaseIterable {
    associatedtype BuilderContext

    static var category: String { get }

    var definition: ActionDefinition<Self> { get }
}

extension ActionProtocol {
    public var identifier: String {
        return "\(type(of: self).category).\(rawValue)"
    }

    public init?(identifier: String) {
        let prefix = Self.category + "."

        if !identifier.starts(with: prefix) {
            return nil
        }

        let ext = String(identifier[prefix.endIndex ..< identifier.endIndex])
        guard let action = Self(rawValue: ext) else {
            return nil
        }

        self = action
    }
}

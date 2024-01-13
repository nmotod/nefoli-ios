import Foundation

public protocol PropertyIterable {
    associatedtype Property: RawRepresentable<String>, CaseIterable
}

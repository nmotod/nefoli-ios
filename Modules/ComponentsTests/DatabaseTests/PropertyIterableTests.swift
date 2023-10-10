@testable import Database
import Difference
import Realm
import RealmSwift
import XCTest

private func assertIterable<T: RLMObjectBase & PropertyIterable>(
    _ objectClass: T.Type,
    file: StaticString = #file,
    line: UInt = #line
) {
    _ = objectClass.Property.allCases

    let schemaProperties = objectClass.sharedSchema()!.properties.map(\.name).sorted()
    let iterableProperties = objectClass.Property.allCases.map(\.rawValue).sorted()

    XCTAssertTrue(
        schemaProperties == iterableProperties,
        "\(objectClass)\n" + diff(schemaProperties, iterableProperties).joined(separator: "\n"),
        file: file,
        line: line
    )
}

final class PropertyIterableTests: XCTestCase {
    /// Tests all object properties are iterable.
    ///
    /// Iterable objects must satifsfy the following conditions:
    ///
    /// 1. All property cases are defined
    /// 2. All property names are correct
    ///
    func testAllPropertiesAreIterable() throws {
        assertIterable(TabGroup.self)
        assertIterable(Tab.self)
    }
}

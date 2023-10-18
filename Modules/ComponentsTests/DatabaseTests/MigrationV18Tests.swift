@testable import Database
import Foundation
import Realm
import RealmSwift
import XCTest

private func loadRealm(fixtureName: String) throws -> Realm {
    let fixtureURL = Bundle.module.url(forResource: fixtureName, withExtension: nil)
    XCTAssertNotNil(fixtureURL)

    var configuration = makeConfiguration()
    configuration.inMemoryIdentifier = UUID().uuidString
    configuration.seedFilePath = fixtureURL

    return try Realm(configuration: configuration)
}

private func dumpObject(_ object: Object) -> [String: Any] {
    return dumpObjectBase(object, objectSchema: object.objectSchema)
}

private func dumpObjectBase(_ object: RLMObjectBase, objectSchema: ObjectSchema) -> [String: Any] {
    var dump = [String: Any]()

    for property in objectSchema.properties {
        guard let value = object.value(forKey: property.name) else { continue }

        dump[property.name] = dumpValue(value)
    }

    return dump
}

private func dumpValue(_ value: Any) -> Any {
    if let list = value as? any Collection {
        return list.map { dumpValue($0) }

    } else if let object = value as? Object {
        return dumpObjectBase(object, objectSchema: object.objectSchema)

    } else if let object = value as? EmbeddedObject {
        return dumpObjectBase(object, objectSchema: object.objectSchema)

    } else if let date = value as? Date {
        return date.formatted()

    } else {
        return value
    }
}

class MigrationV18Tests: XCTestCase {
    func testFromV17() throws {
        let realm = try loadRealm(fixtureName: "v17.realm")

        let rootStates = realm.objects(RootState.self)
        XCTAssertEqual(1, rootStates.count)

        let root = rootStates.first!

        XCTAssertEqual(2, root.groups.count)

        let dump = dumpObject(root)
        try print(String(data: JSONSerialization.data(withJSONObject: dump, options: .prettyPrinted), encoding: .utf8)!)
        
        XCTAssertEqual(2, root.groups.count)
        XCTAssert(root.groups[0] is Object)
    }
}

@testable import Database
import RealmSwift
import XCTest

private func dumpTabGroup(_ group: TabGroup) -> [String] {
    return group.map { tab in
        let s = tab.initialURL?.absoluteString ?? "(no initialURL)"

        if tab.id == group.activeTabId {
            return "* \(s)"
        }

        return s
    }
}

final class TabGroupTests: XCTestCase {
    private var realm: Realm!

    private var rootState: RootState!

    override func setUpWithError() throws {
        realm = try! Realm(configuration: .init(inMemoryIdentifier: UUID().uuidString))

        rootState = RootState()

        try realm.write {
            realm.add(rootState)
        }
    }

    func test() throws {
        try realm.write {
            let group = TabGroup()
            group.add(tab: Tab(), options: .init(activate: false, position: .end))
            group.add(tab: Tab(), options: .init(activate: false, position: .end))

            rootState.groups.append(group)
        }

        guard let rootState = realm.objects(RootState.self).first,
              let group = rootState.groups.first
        else {
            XCTFail()
            return
        }

        XCTAssertEqual(group.count, 2)
    }

    func testAddToEnd() throws {
        let group = TabGroup()

        try realm.write {
            rootState.groups.append(group)

            group.children.append(objectsIn: [
                .init(initialURL: URL(string: "https://example.com/first")!),
                .init(initialURL: URL(string: "https://example.com/second")!),
            ])
        }

        XCTAssertEqual(dumpTabGroup(group), [
            "https://example.com/first",
            "https://example.com/second",
        ])

        try realm.write {
            group.add(tab: .init(initialURL: URL(string: "https://example.com/third")!), options: .init(
                activate: true,
                position: .end
            ))
        }

        XCTAssertEqual(dumpTabGroup(group), [
            "https://example.com/first",
            "https://example.com/second",
            "* https://example.com/third",
        ])
    }

    func testAddAfterActive() throws {
        let group = TabGroup()

        try realm.write {
            rootState.groups.append(group)

            group.children.append(objectsIn: [
                .init(initialURL: URL(string: "https://example.com/first")!),
                .init(initialURL: URL(string: "https://example.com/second")!),
            ])

            group.activeTabId = group[0].id
        }

        XCTAssertEqual(dumpTabGroup(group), [
            "* https://example.com/first",
            "https://example.com/second",
        ])

        try realm.write {
            group.add(tab: .init(initialURL: URL(string: "https://example.com/third")!), options: .init(
                activate: true,
                position: .afterActive
            ))
        }

        XCTAssertEqual(dumpTabGroup(group), [
            "https://example.com/first",
            "* https://example.com/third",
            "https://example.com/second",
        ])
    }

    func testAddAfterTrailingActive() throws {
        let group = TabGroup()

        try realm.write {
            rootState.groups.append(group)

            group.children.append(objectsIn: [
                .init(initialURL: URL(string: "https://example.com/first")!),
                .init(initialURL: URL(string: "https://example.com/second")!),
            ])

            group.activeTabId = group[1].id
        }

        XCTAssertEqual(dumpTabGroup(group), [
            "https://example.com/first",
            "* https://example.com/second",
        ])

        try realm.write {
            group.add(tab: .init(initialURL: URL(string: "https://example.com/third")!), options: .init(
                activate: true,
                position: .afterActive
            ))
        }

        XCTAssertEqual(dumpTabGroup(group), [
            "https://example.com/first",
            "https://example.com/second",
            "* https://example.com/third",
        ])
    }

    func testMove() throws {
        let group = TabGroup()

        try realm.write {
            rootState.groups.append(group)

            group.children.append(objectsIn: [
                .init(initialURL: URL(string: "https://example.com/first")!),
                .init(initialURL: URL(string: "https://example.com/second")!),
                .init(initialURL: URL(string: "https://example.com/third")!),
            ])

            group.activeTabId = group[0].id
        }

        XCTAssertEqual(dumpTabGroup(group), [
            "* https://example.com/first",
            "https://example.com/second",
            "https://example.com/third",
        ])

        try realm.write {
            group.move(from: 2, to: 0)
        }

        XCTAssertEqual(dumpTabGroup(group), [
            "https://example.com/third",
            "* https://example.com/first",
            "https://example.com/second",
        ])
    }

    func testRemoveActive() throws {
        let group = TabGroup()
        
        try realm.write {
            rootState.groups.append(group)
            
            group.children.append(objectsIn: [
                .init(initialURL: URL(string: "https://example.com/first")!),
                .init(initialURL: URL(string: "https://example.com/second")!),
                .init(initialURL: URL(string: "https://example.com/third")!),
            ])
            
            group.activeTabId = group[1].id
        }
        
        XCTAssertEqual(dumpTabGroup(group), [
            "https://example.com/first",
            "* https://example.com/second",
            "https://example.com/third",
        ])
        
        try realm.write {
            group.remove(at: 1)
        }
        
        XCTAssertEqual(dumpTabGroup(group), [
            "https://example.com/first",
            "* https://example.com/third",
        ], "Active tab is next of removed")
    }
}

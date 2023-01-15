@testable import Utilities
import XCTest

final class ActionProtocolTests: XCTestCase {
    enum Action: String, ActionProtocol {
        typealias BuilderContext = Void
        
        static var category: String { "test" }
        
        var definition: ActionDefinition<ActionProtocolTests.Action> {
            fatalError()
        }
        
        case hello
        case goodbye
    }
    
    func testIdentifier() {
        XCTAssertEqual("test.hello", Action.hello.identifier)
        XCTAssertEqual("test.goodbye", Action.goodbye.identifier)
    }
    
    func testFromIdentifier() {
        XCTAssertEqual(Action.hello, Action(identifier: "test.hello"))
        XCTAssertEqual(Action.goodbye, Action(identifier: "test.goodbye"))
    }
}

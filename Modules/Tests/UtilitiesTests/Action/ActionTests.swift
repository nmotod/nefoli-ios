import Combine
@testable import Utilities
import XCTest

final class ActionTests: XCTestCase {
    enum Action: String, ActionProtocol {
        typealias BuilderContext = Void

        static var category: String { "test" }

        case test

        var definition: ActionDefinition<ActionTests.Action> {
            fatalError()
        }
    }

    func testIsEnabledPublisher() throws {
        let subject = CurrentValueSubject<Bool, Never>(false)

        let action = ExecutableAction(
            action: Action.test,
            title: "test",
            isEnabledPublisher: subject.eraseToAnyPublisher()
        ) { _ in }

        var isEnabledSink: Bool?

        let cancellable = action.$isEnabled.sink { isEnabled in
            isEnabledSink = isEnabled
        }

        _ = cancellable

        XCTAssertTrue(isEnabledSink == false, "receive initial value")

        subject.send(true)

        XCTAssertTrue(isEnabledSink == true)
    }
}

import UIKit

public class DrawGesture {
    public enum Direction: CustomDebugStringConvertible {
        case up
        case right
        case down
        case left

        public var debugDescription: String {
            switch self {
            case .up: return "↑"
            case .right: return "→"
            case .down: return "↓"
            case .left: return "←"
            }
        }
    }

    public var strokeDirections: [Direction]

    public var title: String

    public var handler: ((DrawGesture) -> Void)?

    public init(strokeDirections: [Direction], title: String, handler: ((DrawGesture) -> Void)?) {
        self.strokeDirections = strokeDirections
        self.title = title
        self.handler = handler
    }
}

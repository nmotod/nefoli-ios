import UIKit

public class DrawGestureRecognizer: UIGestureRecognizer {
    public var gridSize: CGFloat = 50

    public var tolerancePercent: CGFloat = 0.5

    public var numberOfStrokesRequired = 2

    public var gestures: [DrawGesture] = []

    public private(set) var candidateGestures: [DrawGesture] = []

    public private(set) var recognizedGesture: DrawGesture?

    public private(set) var strokeDirections: [DrawGesture.Direction] = []

    public private(set) var vertices: [CGPoint] = []

    public private(set) var trackingTouch: UITouch?

    override public var state: UIGestureRecognizer.State {
        didSet {
            if state == .ended, let gesture = recognizedGesture {
                gesture.handler?(gesture)
            }
        }
    }

    override public func canBePrevented(by _: UIGestureRecognizer) -> Bool {
        return false
    }

    override public func canPrevent(_: UIGestureRecognizer) -> Bool {
        return true
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        if touches.count != 1 {
            state = .failed
            return
        }

        if trackingTouch == nil {
            let touch = touches.first!
            trackingTouch = touch
            vertices = [touch.location(in: view)]

        } else {
            // Ignore all but the first touch.
            for touch in touches {
                if touch != trackingTouch {
                    ignore(touch, for: event)
                }
            }
        }
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        guard let trackingTouch = trackingTouch,
              let lastVertex = vertices.last,
              // There should be only the first touch.
              touches.first == trackingTouch
        else {
            state = .failed
            return
        }

        let p = trackingTouch.location(in: view)

        let dX = p.x - lastVertex.x
        let dY = p.y - lastVertex.y
        let aX = abs(dX)
        let aY = abs(dY)

        if aY < tolerancePercent * aX {
            if dX <= -gridSize {
                appendStroke(to: .left, vertex: p)

            } else if gridSize <= dX {
                appendStroke(to: .right, vertex: p)
            }
        } else if aX < tolerancePercent * aY {
            if dY <= -gridSize {
                appendStroke(to: .up, vertex: p)

            } else if gridSize <= dY {
                appendStroke(to: .down, vertex: p)
            }
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)

        // There should be only the first touch.
        guard let newTouch = touches.first,
              newTouch == trackingTouch
        else {
            state = .failed
            return
        }

        if numberOfStrokesRequired <= strokeDirections.count,
           recognizedGesture != nil
        {
            state = .ended

        } else {
            state = .failed
        }
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)

        state = .cancelled
    }

    override public func reset() {
        super.reset()

        trackingTouch = nil
        strokeDirections = []
        recognizedGesture = nil
        vertices = []
    }

    private func appendStroke(to dir: DrawGesture.Direction, vertex: CGPoint) {
        if strokeDirections.last == dir {
            vertices.append(vertex)
            return
        }

        vertices.append(vertex)
        strokeDirections.append(dir)

        if strokeDirections.count == numberOfStrokesRequired {
            candidateGestures = filterGestures(gestures, startsWith: strokeDirections)

            if !candidateGestures.isEmpty {
                state = .began
            } else {
                state = .failed
            }

        } else if numberOfStrokesRequired < strokeDirections.count {
            candidateGestures = filterGestures(candidateGestures, startsWith: strokeDirections)

            if !candidateGestures.isEmpty {
                state = .changed
            } else {
                state = .failed
            }
        }

        recognizedGesture = findGesture(candidateGestures, matchesTo: strokeDirections)
    }
}

private func filterGestures(_ gestures: [DrawGesture], startsWith prefixDirections: [DrawGesture.Direction]) -> [DrawGesture] {
    return gestures.filter { g -> Bool in
        if prefixDirections.count <= g.strokeDirections.count {
            let prefix = g.strokeDirections[0 ..< prefixDirections.count]

            if [DrawGesture.Direction](prefix) == prefixDirections {
                return true
            }
        }

        return false
    }
}

private func findGesture(_ gestures: [DrawGesture], matchesTo directions: [DrawGesture.Direction]) -> DrawGesture? {
    return gestures.first { g -> Bool in
        g.strokeDirections == directions
    }
}

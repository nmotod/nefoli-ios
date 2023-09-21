import Foundation
import SwiftUI

/// Allows to dismiss modal instead of pop
public struct OverwritableDismissKey: EnvironmentKey {
    public typealias Value = () -> Void

    public static var defaultValue: Value = {
        fatalError("must be overwritten by .environment(\\.nfl_dismiss, { ... })")
    }
}

extension EnvironmentValues {
    public var nfl_dismiss: () -> Void {
        get { self[OverwritableDismissKey.self] }
        set { self[OverwritableDismissKey.self] = newValue }
    }
}

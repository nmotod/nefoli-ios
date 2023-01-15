import Foundation

extension TabGroup {
    public enum AddingPosition {
        case end
        case afterActive
    }

    public struct AddingOptions {
        var activate: Bool
        var position: AddingPosition
        
        public init(activate: Bool, position: AddingPosition) {
            self.activate = activate
            self.position = position
        }
    }

    public func add(tab: Tab, options: AddingOptions) {
        switch options.position {
        case .end:
            children.append(tab)

        case .afterActive:
            if let activeIndex = activeTabIndex {
                children.insert(tab, at: activeIndex + 1)
            } else {
                children.append(tab)
            }
        }

        if options.activate {
            activeTabId = tab.id
        }
    }
}

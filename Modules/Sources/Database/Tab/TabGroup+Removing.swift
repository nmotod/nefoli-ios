import Foundation

extension TabGroup {
    public func remove(at index: Int) {
        let oldActiveTabIndex = activeTabIndex

        children.remove(at: index)

        // Activate next tab if active tab removed.
        if let oldActiveTabIndex = oldActiveTabIndex,
           oldActiveTabIndex == index
        {
            if index < children.count {
                activeTabIndex = index

            } else if index - 1 >= 0 {
                activeTabIndex = index - 1
            } else {
                activeTabIndex = nil
            }
        }
    }
}

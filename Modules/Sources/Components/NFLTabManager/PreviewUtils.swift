#if DEBUG

import Foundation
import NFLDatabase
import RealmSwift

private func makeTab(title: String, url: String) -> Tab {
    let tab = Tab()

    let current = BackForwardListItem()
    current.title = title
    current.url = URL(string: url)

    tab.current = current

    return tab
}

enum PreviewUtils {
    static let realm = try! Realm(configuration: .init(inMemoryIdentifier: UUID().uuidString))

    @MainActor static var group: TabGroup = {
        let rootState = RootState()

        let group = TabGroup()
        group.add(tab: makeTab(title: "Example.com", url: "https://example.com/"), options: .init(activate: true, position: .end))
        group.add(tab: makeTab(title: "Wikipedia", url: "https://www.wikipedia.org/"), options: .init(activate: true, position: .end))
        group.add(tab: makeTab(title: "Google", url: "https://google.com/"), options: .init(activate: true, position: .end))

        rootState.groups.append(group)

        try! realm.write {
            realm.add(rootState)
        }

        return group
    }()
}

#endif

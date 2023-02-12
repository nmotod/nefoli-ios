import Database
import Foundation
import RealmSwift

#if DEBUG

enum PreviewUtilities {
    static let realm = try! Realm(configuration: .init(inMemoryIdentifier: UUID().uuidString))

    static let settings: Settings = {
        let rootState = RootState()
        let settings = Settings()
        rootState.settings = settings

        try! realm.write {
            realm.add(rootState)
        }

        return settings
    }()
}

#endif

import Foundation
import RealmSwift

public func makeConfiguration() -> Realm.Configuration {
    return Realm.Configuration(
        schemaVersion: schemaVersion,
        migrationBlock: doMigrate(_:oldSchemaVersion:),
        objectTypes: [
            BackForwardListItem.self,
            BookmarkItem.self,
            ContentFilterSetting.self,
            RootState.self,
            Settings.self,
            Tab.self,
            TabGroup.self,
        ]
    )
}

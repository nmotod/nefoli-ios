import Foundation
import os.log
import RealmSwift

let schemaVersion: UInt64 = 13

func doMigrate(_ migration: Migration, oldSchemaVersion: UInt64) {
    let log = Logger(category: "migration")

    log.info("doMigrate - \(oldSchemaVersion, privacy: .public) => \(schemaVersion, privacy: .public)")
}

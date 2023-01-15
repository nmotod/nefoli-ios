import Database
import Foundation
import TabBrowser
import UIKit

private let seedLoader: DatabaseBootstrap.SeedLoader = { () async throws -> RootState? in
    return await Task {
        guard let seedURLString = ProcessInfo.processInfo.environment["NFL_SEED_URL"],
              !seedURLString.isEmpty
        else {
            return nil
        }

        guard let url = URL(string: seedURLString) else {
            print("invalid seed URL: \(seedURLString)")
            return nil
        }
        
        print("Downloading database seed: \(url)")

        let data: Data

        do {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            (data, _) = try await URLSession.shared.data(for: request)
        } catch {
            print("ERROR - Failed to load seed: \(error)")
            return nil
        }

        do {
            let seed = try JSONSerialization.jsonObject(with: data)

            let rootState = RootState(value: seed)
            return rootState
        } catch {
            print("ERROR - Failed to parse seed JSOn: \(error)")
            return nil
        }
    }.value
}

class RootContainerBootstrap {
    static let shared = RootContainerBootstrap()

    var container: RootContainer {
        get async throws { try await bootstrapTask.value }
    }
    
    private let appBundleIdentifier: String

    private let screenshotManager: ScreenshotManager

    private let webViewManager = WebViewManager()

    private let databaseBootstrap: DatabaseBootstrap

    init() {
        appBundleIdentifier = Bundle.main.bundleIdentifier!
               
        screenshotManager = ScreenshotManager(
            screenshotSize: UIScreen.main.bounds.size,
            cachesDirectoryURL: URL.cachesDirectory.appending(path: appBundleIdentifier + ".screenshots")
        )

        databaseBootstrap = .init(
            // configuration: .init(inMemoryIdentifier: UUID().uuidString),
            configuration: .init(),
            seedLoader: seedLoader
        )
    }

    private lazy var bootstrapTask = Task<RootContainer, Error> {
        let db = try await self.databaseBootstrap.database

        return RootContainer(
            appBundleIdentifier: appBundleIdentifier,
            realm: db.realm,
            rootState: db.rootState,
            bookmarksFolder: db.bookmarksFolder,
            favoritesFolder: db.favoritesFolder,
            screenshotManager: screenshotManager,
            webViewManager: webViewManager
        )
    }
}

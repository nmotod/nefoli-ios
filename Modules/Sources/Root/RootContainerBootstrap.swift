import Database
import Foundation
import TabBrowser
import UIKit

private func downloadSeedData(url: URL, maxRetry: Int) async -> Data? {
    for i in 0 ..< maxRetry {
        if i > 0 {
            print("Retrying...")
            try! await Task.sleep(for: .seconds(1))
        }
        
        do {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            let (data, _) = try await URLSession.shared.data(for: request)
            return data
            
        } catch {
            print("ERROR - Failed to load seed: \(error)")
        }
    }
    
    return nil
}

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

        let data = await downloadSeedData(url: url, maxRetry: 3)

        do {
            let seed = try JSONSerialization.jsonObject(with: data!)

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

    let databaseBootstrap: DatabaseBootstrap

    init() {
        appBundleIdentifier = Bundle.main.bundleIdentifier!
               
        screenshotManager = ScreenshotManager(
            screenshotSize: UIScreen.main.bounds.size,
            cachesDirectoryURL: URL.cachesDirectory.appending(path: appBundleIdentifier + ".screenshots")
        )

        databaseBootstrap = .init(seedLoader: seedLoader)
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

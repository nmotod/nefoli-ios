import UIKit

class ScreenshotCacheStorage {
    let cachesDirectoryURL: URL

    private let memoryCache = NSCache<NSString, UIImage>()

    init(cachesDirectoryURL: URL) {
        self.cachesDirectoryURL = cachesDirectoryURL
    }

    func generateFileURL(source: ScreenshotSource) -> URL {
        let url = cachesDirectoryURL.appendingPathComponent("\(source.screenshotKey).jpg")
        return url
    }

    func save(image: UIImage, for source: ScreenshotSource) throws {
        memoryCache.setObject(image, forKey: source.screenshotKey as NSString)

        try ensureCacheDir()

        let url = generateFileURL(source: source)

//        debugLog("[thumbnail] writeCacheFile: \(cachePath)")

        try image.jpegData(compressionQuality: 0.9)?.write(to: url)
    }

    private func ensureCacheDir() throws {
        try FileManager.default.createDirectory(at: cachesDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    }

    func load(source: ScreenshotSource) -> UIImage? {
        if let image = memoryCache.object(forKey: source.screenshotKey as NSString) {
            return image

        } else if let image = loadFile(source: source) {
            memoryCache.setObject(image, forKey: source.screenshotKey as NSString)
            return image
        }

        return nil
    }

    private func loadFile(source: ScreenshotSource) -> UIImage? {
        let url = generateFileURL(source: source)

        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }

//        debugLog("[thumbnail] loadCacheFileIfExists: \(path)")

        let data = try! Data(contentsOf: url)

        let image = UIImage(data: data)

        return image
    }

    func delete(source: ScreenshotSource) throws {
        memoryCache.removeObject(forKey: source.screenshotKey as NSString)

        let url = generateFileURL(source: source)

        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}

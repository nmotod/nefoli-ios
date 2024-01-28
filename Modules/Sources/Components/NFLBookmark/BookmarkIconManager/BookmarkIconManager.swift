import Foundation
import LinkPresentation
import NFLDatabase
import UIKit

public class BookmarkIconManager {
    let maxSize: CGSize

    let cachesDirectoryURL: URL

    let metadataProviderFactory: () -> LPMetadataProvider

    public init(
        maxSize: CGSize,
        cachesDirectoryURL: URL,
        metadataProviderFactory: @escaping () -> LPMetadataProvider = LPMetadataProvider.init
    ) {
        self.maxSize = maxSize
        self.cachesDirectoryURL = cachesDirectoryURL
        self.metadataProviderFactory = metadataProviderFactory
    }

    @MainActor
    public func getImage(for item: BookmarkItem) async throws -> UIImage? {
        if let remoteIconExists = item.remoteIconExists, !remoteIconExists { return nil }

        guard let webpageURL = item.url else { return nil }

        let fileURL = cacheFileURL(for: item)

        if FileManager.default.fileExists(atPath: fileURL.path),
           let image = UIImage(contentsOfFile: fileURL.path)
        {
            return image
        }

        guard let metadata = try? await metadataProviderFactory().startFetchingMetadata(for: webpageURL),
              var image = try? await metadata.fetchIconImage()
        else {
            try item.realm!.write {
                item.remoteIconExists = false
            }

            return nil
        }

        try item.realm!.write {
            item.remoteIconExists = true
        }

        if image.size.width > maxSize.width || image.size.height > maxSize.height {
            image = await image.byPreparingThumbnail(ofSize: maxSize)!
        }

        try! save(image: image, fileURL: fileURL)
        return image
    }

    func cacheFileURL(for item: BookmarkItem) -> URL {
        return cachesDirectoryURL.appending(component: item.id.persistableValue)
    }

    private func save(image: UIImage, fileURL: URL) throws {
        guard let data = image.pngData() else { return }

        try FileManager.default.createDirectory(at: cachesDirectoryURL, withIntermediateDirectories: true)

        try data.write(to: fileURL)
    }
}

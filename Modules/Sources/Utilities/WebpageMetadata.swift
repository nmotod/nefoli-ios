import LinkPresentation
import UIKit

public class WebpageMetadata: NSObject, UIActivityItemSource {
    public let title: String

    public let url: URL

    public let lpMetadata = LPLinkMetadata()

    private var isFetchingOrFetched = false

    public init(title: String, url: URL) {
        self.title = title
        self.url = url
        lpMetadata.title = title
        lpMetadata.url = url

        super.init()
    }

    public func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return url
    }

    public func activityViewController(_: UIActivityViewController, itemForActivityType _: UIActivity.ActivityType?) -> Any? {
        return url
    }

    public func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        Task { @MainActor in
            fetchMetadataIfNeeded()
        }
        
        return lpMetadata
    }

    @MainActor
    private func fetchMetadataIfNeeded() {
        guard !isFetchingOrFetched else { return }

        isFetchingOrFetched = true

        // startFetchingMetadata() must be called in main thread.
        LPMetadataProvider().startFetchingMetadata(for: url) { metadata, _ in
            guard let metadata = metadata else { return }

            DispatchQueue.main.async {
                self.lpMetadata.iconProvider = metadata.iconProvider
            }
        }
    }
}

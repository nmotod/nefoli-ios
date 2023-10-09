import Foundation
import LinkPresentation
import UIKit

extension LPLinkMetadata {
    func fetchIconImage() async throws -> UIImage? {
        guard let iconProvider = iconProvider else { return nil }

        if iconProvider.canLoadObject(ofClass: UIImage.self) {
            return try await withCheckedThrowingContinuation { continuation in
                iconProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let error {
                        continuation.resume(with: .failure(error))
                        return
                    }

                    continuation.resume(with: .success(object as? UIImage))
                }
            }

        } else if let identifier = iconProvider.registeredTypeIdentifiers.first {
            // for ICO file
            return try await withCheckedThrowingContinuation { continuation in
                iconProvider.loadItem(forTypeIdentifier: identifier) { item, error in
                    if let error {
                        continuation.resume(with: .failure(error))
                        return
                    }

                    if let data = item as? Data,
                       let image = UIImage(data: data)
                    {
                        continuation.resume(with: .success(image))

                    } else {
                        continuation.resume(with: .success(nil))
                    }
                }
            }
        }

        return nil
    }
}

import Foundation
import PhotosUI
import _PhotosUI_SwiftUI

/// Handles importing images from the photo library into canvas objects.
/// Saves images to the app's documents directory for persistence.
enum ImageImportService {

    // MARK: - Configuration

    private static let imageDir = "canvas_images"

    // MARK: - Path
    private static let imageDir = "canvas_images"

    private static var directoryURL: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent(imageDir)
    }

    // MARK: - Save / Load / Delete

    /// Save image data to disk and return a MediaAsset.
    static func saveImage(data: Data, fileName: String) -> MediaAsset? {
        // Ensure directory exists
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        let id = UUID()
        let fileURL = directoryURL.appendingPathComponent("\(id.uuidString).jpg")

        do {
            try data.write(to: fileURL, options: .atomic)
            return MediaAsset(
                id: id,
                kind: .image,
                fileName: fileName,
                localURL: fileURL,
                thumbnailData: nil,
                createdAt: Date()
            )
        } catch {
            return nil
        }
    }

    /// Load image from a MediaAsset's local URL.
    static func loadImage(from asset: MediaAsset) -> UIImage? {
        guard let url = asset.localURL else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    /// Delete saved image file.
    static func deleteImage(asset: MediaAsset) {
        guard let url = asset.localURL else { return }
        try? FileManager.default.removeItem(at: url)
    }

    /// Load a PhotosPickerItem and return image data.
    static func loadData(from item: PhotosPickerItem) async -> Data? {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return nil }
        return data
    }
}

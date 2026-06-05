import PDFKit
import Photos
import SwiftUI
import PencilKit

/// Renders the canvas content to a UIImage for export or sharing.
enum CanvasExporter {

    /// Render the canvas to a UIImage.
    /// Combines PencilKit drawing + canvas objects into a single image.
    static func renderToImage(
        drawing: PKDrawing,
        objects: [CanvasObject],
        canvasSize: CGSize,
        scale: CGFloat = 2.0
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: canvasSize)

        return renderer.image { context in
            let cgContext = context.cgContext

            // White background — exports always use light background for
            // printability and sharing, regardless of canvas dark-mode state.
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fill(CGRect(origin: .zero, size: canvasSize))

            // Draw PencilKit ink
            let inkImage = drawing.image(from: drawing.bounds, scale: scale)
            inkImage.draw(at: .zero)

            // Draw canvas objects via shared renderer
            for obj in objects {
                CanvasObjectRenderer.draw(obj, in: cgContext, scale: scale)
            }
        }
    }

    /// Save image to Photos library.
    static func saveToPhotos(_ image: UIImage) async -> Bool {
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.creationRequestForAsset(from: image)
            }
            return true
        } catch {
            return false
        }
    }

    /// Create a shareable URL for the image.
    static func saveToTemporaryURL(_ image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: Brand.exportCompressionQuality) else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("inkpilot_export.jpg")
        try? data.write(to: url, options: .atomic)
        return url
    }
}

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

            // White background
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fill(CGRect(origin: .zero, size: canvasSize))

            // Draw PencilKit ink
            let inkImage = drawing.image(from: drawing.bounds, scale: scale)
            inkImage.draw(at: .zero)

            // Draw canvas objects (simplified — just renders text cards)
            for obj in objects {
                drawObject(obj, in: cgContext, scale: scale)
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
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("inkpilot_export.jpg")
        try? data.write(to: url, options: .atomic)
        return url
    }

    // MARK: - Private

    private static func drawObject(_ obj: CanvasObject, in context: CGContext, scale: CGFloat) {
        let rect = CGRect(
            x: obj.worldPosition.x * scale,
            y: obj.worldPosition.y * scale,
            width: obj.size.width * scale,
            height: obj.size.height * scale
        )

        switch obj.content {
        case .aiCard(let title, let body), .mindNode(let title, _):
            drawTextCard(title: title, body: body, in: rect, context: context, scale: scale)
        case .text(let text):
            drawTextCard(title: text, body: "", in: rect, context: context, scale: scale)
        case .stickyNote(let text):
            drawStickyNote(text: text, in: rect, context: context, scale: scale)
        case .bubble(let text):
            drawTextCard(title: text, body: "", in: rect, context: context, scale: scale)
        default:
            break
        }
    }

    private static func drawTextCard(title: String, body: String, in rect: CGRect, context: CGContext, scale: CGFloat) {
        // Draw card background
        context.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 8 * scale)
        path.fill()
        path.stroke()

        // Draw title
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14 * scale, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        let titleRect = rect.insetBy(dx: 12 * scale, dy: 8 * scale)
        (title as NSString).draw(in: titleRect, withAttributes: titleAttrs)

        // Draw body
        if !body.isEmpty {
            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11 * scale),
                .foregroundColor: UIColor.darkGray
            ]
            let bodyRect = CGRect(
                x: titleRect.minX,
                y: titleRect.maxY + 4 * scale,
                width: titleRect.width,
                height: rect.maxY - titleRect.maxY - 12 * scale
            )
            (body as NSString).draw(in: bodyRect, withAttributes: bodyAttrs)
        }
    }

    private static func drawStickyNote(text: String, in rect: CGRect, context: CGContext, scale: CGFloat) {
        context.setFillColor(UIColor.systemYellow.withAlphaComponent(0.3).cgColor)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 6 * scale)
        path.fill()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11 * scale),
            .foregroundColor: UIColor.black
        ]
        (text as NSString).draw(in: rect.insetBy(dx: 8 * scale, dy: 8 * scale), withAttributes: attrs)
    }
}

import Photos

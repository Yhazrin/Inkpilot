import Foundation
import PDFKit
import UIKit
import PencilKit

/// Handles PDF import, rendering, and text extraction.
enum PDFService {

    // MARK: - Import

    /// Load a PDF from a file URL and return page data.
    static func importPDF(from url: URL) -> PDFDocument? {
        guard url.startAccessingSecurityScopedResource() else {
            return PDFDocument(url: url)
        }
        defer { url.stopAccessingSecurityScopedResource() }
        return PDFDocument(url: url)
    }

    /// Render a specific PDF page to UIImage.
    static func renderPage(_ page: PDFPage, at size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fill(CGRect(origin: .zero, size: size))

            cgContext.saveGState()
            cgContext.translateBy(x: 0, y: size.height)
            cgContext.scaleBy(x: 1, y: -1)

            let pageRect = page.bounds(for: .mediaBox)
            let scaleX = size.width / pageRect.width
            let scaleY = size.height / pageRect.height
            let scale = min(scaleX, scaleY)

            cgContext.scaleBy(x: scale, y: scale)
            cgContext.translateBy(x: -pageRect.origin.x, y: -pageRect.origin.y)

            page.draw(with: .mediaBox, to: cgContext)
            cgContext.restoreGState()
        }
    }

    // MARK: - Text Extraction

    /// Extract all text from a PDF document.
    static func extractText(from document: PDFDocument) -> String {
        var text = ""
        for i in 0..<document.pageCount {
            if let page = document.page(at: i),
               let pageText = page.string {
                text += pageText + "\n"
            }
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Extract text from a single page.
    static func extractText(from page: PDFPage) -> String {
        page.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    // MARK: - Export

    /// Render canvas content to a PDF document.
    static func exportToPDF(
        drawing: PKDrawing,
        objects: [CanvasObject],
        pageSize: CGSize = CGSize(width: 612, height: 792) // US Letter
    ) -> Data? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

        return renderer.pdfData { context in
            context.beginPage()

            let cgContext = context.cgContext

            // White background
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fill(CGRect(origin: .zero, size: pageSize))

            // Draw PencilKit ink
            let inkImage = drawing.image(from: drawing.bounds, scale: 2.0)
            let inkRect = CGRect(origin: .zero, size: pageSize)
            inkImage.draw(in: inkRect)

            // Draw canvas objects (simplified)
            for obj in objects {
                drawObjectForPDF(obj, in: cgContext, pageSize: pageSize)
            }
        }
    }

    // MARK: - Private

    private static func drawObjectForPDF(_ obj: CanvasObject, in context: CGContext, pageSize: CGSize) {
        let rect = CGRect(
            x: obj.worldPosition.x,
            y: obj.worldPosition.y,
            width: obj.size.width,
            height: obj.size.height
        )

        switch obj.content {
        case .aiCard(let title, let body):
            drawPDFTextCard(title: title, body: body, in: rect, context: context)
        case .mindNode(let title, _):
            drawPDFTextCard(title: title, body: "", in: rect, context: context)
        case .text(let text):
            drawPDFTextCard(title: text, body: "", in: rect, context: context)
        case .stickyNote(let text):
            context.setFillColor(UIColor.systemYellow.withAlphaComponent(0.3).cgColor)
            UIBezierPath(roundedRect: rect, cornerRadius: 6).fill()
            (text as NSString).draw(in: rect.insetBy(dx: 8, dy: 8), withAttributes: [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.black
            ])
        case .bubble(let text):
            drawPDFTextCard(title: text, body: "", in: rect, context: context)
        case .shape(let kind):
            context.setStrokeColor(UIColor.darkGray.cgColor)
            context.setLineWidth(1.5)
            pdfShapePath(kind: kind, in: rect).stroke()
        case .connector:
            context.setStrokeColor(UIColor.gray.cgColor)
            context.setLineWidth(1)
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.stroke()
        case .media:
            context.setFillColor(UIColor.lightGray.withAlphaComponent(0.2).cgColor)
            UIBezierPath(roundedRect: rect, cornerRadius: 6).fill()
        case .pdfPage:
            context.setFillColor(UIColor.lightGray.withAlphaComponent(0.15).cgColor)
            UIBezierPath(roundedRect: rect, cornerRadius: 4).fill()
        }
    }

    private static func drawPDFTextCard(title: String, body: String, in rect: CGRect, context: CGContext) {
        context.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(0.5)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
        path.fill()
        path.stroke()

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        (title as NSString).draw(in: rect.insetBy(dx: 12, dy: 8), withAttributes: titleAttrs)

        if !body.isEmpty {
            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.darkGray
            ]
            let bodyRect = CGRect(x: rect.minX + 12, y: rect.minY + 28, width: rect.width - 24, height: rect.height - 36)
            (body as NSString).draw(in: bodyRect, withAttributes: bodyAttrs)
        }
    }

    private static func pdfShapePath(kind: CanvasShapeKind, in rect: CGRect) -> UIBezierPath {
        switch kind {
        case .rectangle: return UIBezierPath(rect: rect)
        case .roundedRectangle: return UIBezierPath(roundedRect: rect, cornerRadius: 8)
        case .ellipse: return UIBezierPath(ovalIn: rect)
        case .diamond:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.close()
            return path
        case .arrow, .line:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            return path
        }
    }
}

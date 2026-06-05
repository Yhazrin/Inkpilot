import Foundation
import PDFKit
import SwiftUI
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
        pageSize: CGSize = Brand.pdfLetterPageSize
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

            // Draw canvas objects via shared renderer (scale=1 for PDF coordinates)
            for obj in objects {
                CanvasObjectRenderer.draw(obj, in: cgContext, scale: 1.0)
            }
        }
    }
}

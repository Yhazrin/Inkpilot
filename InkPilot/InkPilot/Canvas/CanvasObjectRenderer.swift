import UIKit
import PDFKit

/// Shared rendering logic for canvas objects in CGContext.
/// Used by both CanvasExporter (image export) and PDFService (PDF export).
enum CanvasObjectRenderer {

    /// Draw a single canvas object into the given context.
    /// - Parameters:
    ///   - obj: The canvas object to render.
    ///   - context: The Core Graphics context to draw into.
    ///   - scale: Coordinate scale factor (2.0 for retina image export, 1.0 for PDF).
    static func draw(_ obj: CanvasObject, in context: CGContext, scale: CGFloat = 1.0) {
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
        case .shape(let kind):
            drawShape(kind: kind, in: rect, context: context, scale: scale)
        case .connector:
            drawConnector(in: rect, context: context, scale: scale)
        case .media:
            drawMediaPlaceholder(in: rect, context: context, scale: scale)
        case .pdfPage(let pdfURL, let pageIndex):
            drawPDFPage(pdfURL: pdfURL, pageIndex: pageIndex, in: rect, context: context, scale: scale)
        }
    }

    // MARK: - Text Card

    static func drawTextCard(title: String, body: String, in rect: CGRect, context: CGContext, scale: CGFloat) {
        context.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(max(0.5, scale * 0.5))
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 8 * scale)
        path.fill()
        path.stroke()

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14 * scale, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        let titleRect = rect.insetBy(dx: 12 * scale, dy: 8 * scale)
        (title as NSString).draw(in: titleRect, withAttributes: titleAttrs)

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

    // MARK: - Shape

    static func drawShape(kind: CanvasShapeKind, in rect: CGRect, context: CGContext, scale: CGFloat) {
        context.setStrokeColor(UIColor.darkGray.cgColor)
        context.setLineWidth(2 * scale)
        shapePath(kind: kind, in: rect).stroke()
    }

    static func shapePath(kind: CanvasShapeKind, in rect: CGRect) -> UIBezierPath {
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

    // MARK: - Sticky Note

    static func drawStickyNote(text: String, in rect: CGRect, context: CGContext, scale: CGFloat) {
        context.setFillColor(UIColor.systemYellow.withAlphaComponent(0.3).cgColor)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 6 * scale)
        path.fill()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11 * scale),
            .foregroundColor: UIColor.black
        ]
        (text as NSString).draw(in: rect.insetBy(dx: 8 * scale, dy: 8 * scale), withAttributes: attrs)
    }

    // MARK: - Connector

    static func drawConnector(in rect: CGRect, context: CGContext, scale: CGFloat) {
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setLineWidth(1.5 * scale)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.stroke()
    }

    // MARK: - Media Placeholder

    static func drawMediaPlaceholder(in rect: CGRect, context: CGContext, scale: CGFloat) {
        context.setFillColor(UIColor.lightGray.withAlphaComponent(0.2).cgColor)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 6 * scale)
        path.fill()
        context.setStrokeColor(UIColor.lightGray.cgColor)
        path.stroke()
    }

    // MARK: - PDF Page

    static func drawPDFPage(pdfURL: String?, pageIndex: Int, in rect: CGRect, context: CGContext, scale: CGFloat) {
        guard let pdfURL, let url = URL(string: pdfURL),
              let document = PDFDocument(url: url),
              let page = document.page(at: pageIndex) else {
            drawMediaPlaceholder(in: rect, context: context, scale: scale)
            return
        }
        if let image = PDFService.renderPage(page, at: rect.size) {
            image.draw(in: rect)
        }
    }
}

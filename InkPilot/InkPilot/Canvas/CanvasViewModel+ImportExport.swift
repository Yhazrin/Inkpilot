import PDFKit
import SwiftUI
import PencilKit

/// Image/PDF import and canvas export for CanvasViewModel.
extension CanvasViewModel {

    // MARK: - Image Import

    func importImage(data: Data, fileName: String) {
        guard let asset = ImageImportService.saveImage(data: data, fileName: fileName) else { return }
        let obj = CanvasObject(
            id: UUID(),
            content: .media(assetID: asset.id.uuidString, mediaKind: .image),
            worldPosition: defaultInsertionPoint,
            size: CGSizeCodable(width: 300, height: 200),
            rotation: 0, zIndex: 0, groupID: nil,
            source: .user, style: .default,
            createdAt: Date(), updatedAt: Date()
        )
        addObject(obj)
    }

    // MARK: - PDF Import

    func importPDF(from url: URL) {
        guard let document = PDFService.importPDF(from: url) else { return }
        let urlString = url.absoluteString
        let pageSpacing: CGFloat = 620

        for i in 0..<document.pageCount {
            let obj = CanvasObject(
                id: UUID(),
                content: .pdfPage(pdfURL: urlString, pageIndex: i),
                worldPosition: CGPointCodable(
                    x: defaultInsertionPoint.x,
                    y: defaultInsertionPoint.y + CGFloat(i) * pageSpacing
                ),
                size: CGSizeCodable(width: 400, height: 560),
                rotation: 0, zIndex: 0, groupID: nil,
                source: .user, style: .default,
                createdAt: Date(), updatedAt: Date()
            )
            addObject(obj)
        }
    }

    // MARK: - Canvas Export

    func exportCanvasAsImage(screenSize: CGSize) -> UIImage {
        CanvasExporter.renderToImage(drawing: drawing, objects: canvasObjects, canvasSize: screenSize)
    }

    func exportToPhotos(screenSize: CGSize) async -> Bool {
        let image = exportCanvasAsImage(screenSize: screenSize)
        return await CanvasExporter.saveToPhotos(image)
    }

    func exportToShareURL(screenSize: CGSize) -> URL? {
        let image = exportCanvasAsImage(screenSize: screenSize)
        return CanvasExporter.saveToTemporaryURL(image)
    }

    func exportAsPDF() -> Data? {
        PDFService.exportToPDF(drawing: drawing, objects: canvasObjects)
    }

    func exportPDFToShareURL() -> URL? {
        guard let data = exportAsPDF() else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("inkpilot_export.pdf")
        try? data.write(to: url, options: .atomic)
        return url
    }
}

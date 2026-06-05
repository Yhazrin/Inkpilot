import Foundation
import PencilKit

/// Builds a `CanvasContext` from the current canvas state.
enum CanvasContextBuilder {

    static func build(
        from drawing: PKDrawing,
        canvasObjects: [CanvasObject] = [],
        selectedObjectID: UUID? = nil,
        promptText: String = ""
    ) -> CanvasContext {
        let strokeCount = drawing.strokes.count
        let hasInk = strokeCount > 0
        let bounds = drawing.bounds

        var inkParts: [String] = []
        if hasInk {
            inkParts.append("User has drawn \(strokeCount) stroke(s)")
            if bounds.width > 0 {
                inkParts.append("Ink bounds: \(Int(bounds.width))x\(Int(bounds.height))")
            }
        } else {
            inkParts.append("Empty canvas (no ink)")
        }

        // Object summaries for AI context
        let objectSummaries = canvasObjects.map { obj in
            let title: String
            switch obj.content {
            case .aiCard(let t, _): title = t
            case .text(let t): title = t
            case .stickyNote(let t): title = t
            case .bubble(let t): title = t
            case .shape(let k): title = k.rawValue
            case .connector: title = "connector"
            case .media(_, let k): title = k.rawValue
            case .mindNode(let label, _): title = label
            case .pdfPage(_, let pageIndex): title = "PDF page \(pageIndex)"
            }
            return CanvasObjectSummary(type: obj.content.typeName, title: title)
        }

        // Selected object summary — look up by matching object ID, not by type
        var selectedSummary: String? = nil
        if let selectedID = selectedObjectID,
           let selected = canvasObjects.first(where: { $0.id == selectedID }),
           let selectedIndex = canvasObjects.firstIndex(where: { $0.id == selectedID }),
           selectedIndex < objectSummaries.count {
            let summary = objectSummaries[selectedIndex]
            selectedSummary = "\(summary.type): \(summary.title)"
        }

        // Locale
        let locale = Locale.current.language.languageCode?.identifier ?? "en"
        let localeStr = locale == "zh" ? "zh-Hans" : "en"

        return CanvasContext(
            inkText: inkParts.joined(separator: "; "),
            promptText: promptText,
            selectedObjectSummary: selectedSummary,
            canvasObjectSummaries: objectSummaries,
            locale: localeStr
        )
    }
}

// MARK: - Content type name helper

private extension CanvasObjectContent {
    var typeName: String {
        switch self {
        case .aiCard: return "aiCard"
        case .text: return "text"
        case .stickyNote: return "stickyNote"
        case .bubble: return "bubble"
        case .shape: return "shape"
        case .connector: return "connector"
        case .mindNode: return "mindNode"
        case .media: return "media"
        case .pdfPage: return "pdfPage"
        }
    }
}

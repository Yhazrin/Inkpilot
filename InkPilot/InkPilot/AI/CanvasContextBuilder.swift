import Foundation
import PencilKit

/// Builds a `CanvasContext` from the current canvas state.
/// V0.2: includes stroke info, canvas objects summary, selected object,
/// and prompt text. OCR can be layered on later.
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

        var parts: [String] = []

        if hasInk {
            parts.append("User has drawn \(strokeCount) stroke(s)")
            if bounds.width > 0 {
                parts.append("Ink bounds: \(Int(bounds.width))x\(Int(bounds.height))")
            }
        } else {
            parts.append("Empty canvas (no ink)")
        }

        if !canvasObjects.isEmpty {
            let typeCounts = Dictionary(grouping: canvasObjects, by: { $0.type })
                .mapValues { $0.count }
            let summary = typeCounts.map { "\($0.key.rawValue): \($0.value)" }.joined(separator: ", ")
            parts.append("Canvas objects: \(summary)")
        }

        if let selectedID = selectedObjectID,
           let selected = canvasObjects.first(where: { $0.id == selectedID }) {
            parts.append("Selected: \(selected.type.rawValue) \"\(selected.title)\"")
        }

        if !promptText.isEmpty {
            parts.append("User prompt: \"\(promptText)\"")
        }

        return CanvasContext(inkText: parts.joined(separator: "; "))
    }
}

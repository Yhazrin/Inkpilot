import Foundation
import PencilKit

/// Builds a `CanvasContext` from the current canvas state.
/// V0.1: returns mock context. Future: render ink snapshot → Vision OCR → structured context.
enum CanvasContextBuilder {

    static func build(from drawing: PKDrawing) -> CanvasContext {
        // V0.1: derive context from drawing state
        // Future: InkSnapshotRenderer → VisionOCRService → rich context
        let hasInk = !drawing.strokes.isEmpty
        let inkText = hasInk ? "User has drawn \(drawing.strokes.count) stroke(s)" : "Empty canvas"
        return CanvasContext(inkText: inkText)
    }
}

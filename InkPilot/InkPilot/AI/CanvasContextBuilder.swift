import Foundation
import PencilKit

/// Builds a `CanvasContext` from the current canvas state.
/// V0.1: stub. Future: extract ink regions, run Vision OCR, build rich context.
enum CanvasContextBuilder {

    static func build(from drawing: PKDrawing) -> CanvasContext {
        // V0.1 stub — future: render ink snapshot → OCR → structured context
        return CanvasContext(inkText: "")
    }
}

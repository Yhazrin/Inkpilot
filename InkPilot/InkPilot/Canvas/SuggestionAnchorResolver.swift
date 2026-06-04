import Foundation
import PencilKit

/// Decides where on the canvas a new AI suggestion "comes from".
///
/// V0.1: returns a stable, mockable point. If there is recent ink we use
/// the center of the most recent stroke's bounds; otherwise we use a
/// fallback near the visible upper-middle of the canvas.
///
/// Future: hook into an `InkSnapshotRenderer` / `VisionOCRService` pipeline
/// to pick a more semantic anchor (the paragraph the user just wrote,
/// the area of the canvas with the most ink, etc.).
enum SuggestionAnchorResolver {

    static func resolve(
        drawing: PKDrawing,
        fallback: CGPoint
    ) -> CGPoint {
        guard let lastStroke = drawing.strokes.last else {
            return fallback
        }
        let bounds = lastStroke.renderBounds
        guard bounds.width > 0, bounds.height > 0 else {
            return fallback
        }
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
}

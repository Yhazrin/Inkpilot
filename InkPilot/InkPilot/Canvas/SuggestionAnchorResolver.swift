import Foundation
import PencilKit

/// Derives the canvas-space point that "birthed" an AI suggestion.
///
/// V0.1: pure derivation, no OCR. If there is recent ink we return the
/// center of the most recent stroke's render bounds. If the canvas is
/// empty we return a stable fallback in the center-left of the visible
/// canvas so the ghost still feels born from the page, not from the
/// center of the screen.
///
/// The output is screen-space-ish in V0.1 because real pan/zoom is
/// intentionally out of scope. Once an infinite-canvas model lands
/// this function will return world-space instead.
enum SuggestionAnchorResolver {

    /// Resolve a suggestion anchor for a given drawing.
    ///
    /// - Parameters:
    ///   - drawing: The current `PKDrawing` on the canvas.
    ///   - fallback: A point returned when the drawing is empty. Callers
    ///     can supply a value tuned to their layout.
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

    /// A default fallback suitable for an iPad canvas: roughly the
    /// center-left of the visible area, well clear of the toolbar and
    /// AI Pilot panel.
    static let defaultFallback = CGPoint(x: 520, y: 360)
}

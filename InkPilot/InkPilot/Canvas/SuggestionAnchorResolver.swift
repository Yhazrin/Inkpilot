import Foundation
import PencilKit
import SwiftUI

/// Derives the canvas-space point that "birthed" an AI suggestion.
///
/// Derives a suggestion anchor. If there is recent ink we return the
/// center of the most recent stroke's render bounds. If the canvas is
/// empty we return a stable fallback.
enum SuggestionAnchorResolver {

    static func resolve(drawing: PKDrawing, fallback: CGPoint) -> CGPoint {
        guard let lastStroke = drawing.strokes.last else { return fallback }
        let bounds = lastStroke.renderBounds
        guard bounds.width > 0, bounds.height > 0 else { return fallback }
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }

    /// Default fallback: center-left of visible area, clear of toolbar and AI panel.
    static let defaultFallback = Brand.defaultInsertionPoint.cgPoint
}

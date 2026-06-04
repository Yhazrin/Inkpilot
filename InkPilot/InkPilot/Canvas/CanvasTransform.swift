import SwiftUI

/// Represents the canvas viewport: zoom scale and pan offset.
/// All world-to-screen and screen-to-world conversions go through here.
struct CanvasTransform: Equatable {
    /// Zoom scale (1.0 = 100%).
    var scale: CGFloat = 1.0
    /// Pan offset in screen points (how far the viewport has scrolled).
    var offset: CGSize = .zero

    // MARK: - Coordinate conversion

    /// Convert a world-space point to screen-space.
    func worldToScreen(_ worldPoint: CGPoint) -> CGPoint {
        CGPoint(
            x: worldPoint.x * scale + offset.width,
            y: worldPoint.y * scale + offset.height
        )
    }

    /// Convert a screen-space point to world-space.
    func screenToWorld(_ screenPoint: CGPoint) -> CGPoint {
        CGPoint(
            x: (screenPoint.x - offset.width) / scale,
            y: (screenPoint.y - offset.height) / scale
        )
    }

    /// Convert a world-space size to screen-space.
    func worldToScreenSize(_ worldSize: CGSize) -> CGSize {
        CGSize(width: worldSize.width * scale, height: worldSize.height * scale)
    }

    // MARK: - Viewport helpers

    /// The visible world-space rect for a given screen size.
    func visibleWorldRect(screenSize: CGSize) -> CGRect {
        let origin = screenToWorld(.zero)
        let end = screenToWorld(CGPoint(x: screenSize.width, y: screenSize.height))
        return CGRect(
            x: origin.x,
            y: origin.y,
            width: end.x - origin.x,
            height: end.y - origin.y
        )
    }

    // MARK: - Codable wrapper

    var codable: CanvasTransformCodable {
        CanvasTransformCodable(scale: scale, offsetWidth: offset.width, offsetHeight: offset.height)
    }

    static let identity = CanvasTransform()
}

/// Codable representation of CanvasTransform for persistence.
struct CanvasTransformCodable: Codable {
    var scale: CGFloat
    var offsetWidth: CGFloat
    var offsetHeight: CGFloat

    var transform: CanvasTransform {
        CanvasTransform(scale: scale, offset: CGSize(width: offsetWidth, height: offsetHeight))
    }
}

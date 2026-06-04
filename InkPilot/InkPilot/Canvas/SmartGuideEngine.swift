import Foundation

/// A guide line that appears when objects align during drag.
struct GuideLine: Equatable {
    enum Orientation { case horizontal, vertical }
    let orientation: Orientation
    let position: CGFloat  // world coordinate
    let start: CGFloat     // perpendicular start
    let end: CGFloat       // perpendicular end
}

/// Computes alignment guide lines between a dragged object and other objects.
/// Returns guides within a snap threshold and optionally snaps the position.
enum SmartGuideEngine {
    static let snapThreshold: CGFloat = 8.0

    /// Find guide lines and optionally snap the dragged object's position.
    /// Returns (adjusted position, visible guide lines).
    static func compute(
        draggedObject: CanvasObject,
        proposedPosition: CGPointCodable,
        otherObjects: [CanvasObject]
    ) -> (position: CGPointCodable, guides: [GuideLine]) {
        let dx = proposedPosition.x
        let dy = proposedPosition.y
        let dw = draggedObject.size.width
        let dh = draggedObject.size.height
        let dCenterX = dx + dw / 2
        let dCenterY = dy + dh / 2

        var guides: [GuideLine] = []
        var snapX: CGFloat? = nil
        var snapY: CGFloat? = nil

        for other in otherObjects where other.id != draggedObject.id {
            let ox = other.worldPosition.x
            let oy = other.worldPosition.y
            let ow = other.size.width
            let oh = other.size.height
            let oCenterX = ox + ow / 2
            let oCenterY = oy + oh / 2

            // Vertical guides (x-alignment)
            let xChecks: [(CGFloat, CGFloat)] = [
                (dx, ox),              // left-left
                (dx + dw, ox + ow),    // right-right
                (dCenterX, oCenterX),  // center-center
                (dx, ox + ow),         // left-right
                (dx + dw, ox),         // right-left
            ]
            for (dragEdge, otherEdge) in xChecks {
                if abs(dragEdge - otherEdge) < snapThreshold {
                    snapX = otherEdge - (dragEdge - dx)
                    let minY = min(dy, oy)
                    let maxY = max(dy + dh, oy + oh)
                    guides.append(GuideLine(
                        orientation: .vertical,
                        position: otherEdge,
                        start: minY - 20,
                        end: maxY + 20
                    ))
                }
            }

            // Horizontal guides (y-alignment)
            let yChecks: [(CGFloat, CGFloat)] = [
                (dy, oy),              // top-top
                (dy + dh, oy + oh),    // bottom-bottom
                (dCenterY, oCenterY),  // middle-middle
                (dy, oy + oh),         // top-bottom
                (dy + dh, oy),         // bottom-top
            ]
            for (dragEdge, otherEdge) in yChecks {
                if abs(dragEdge - otherEdge) < snapThreshold {
                    snapY = otherEdge - (dragEdge - dy)
                    let minX = min(dx, ox)
                    let maxX = max(dx + dw, ox + ow)
                    guides.append(GuideLine(
                        orientation: .horizontal,
                        position: otherEdge,
                        start: minX - 20,
                        end: maxX + 20
                    ))
                }
            }
        }

        let finalPos = CGPointCodable(
            x: snapX ?? dx,
            y: snapY ?? dy
        )
        return (finalPos, guides)
    }
}

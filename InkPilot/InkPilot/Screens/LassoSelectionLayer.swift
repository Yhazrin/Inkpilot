import SwiftUI

/// A freeform lasso drawn by finger drag to select objects.
/// The user draws a closed path; objects whose centers fall inside are selected.
struct LassoSelectionLayer: View {
    let isActive: Bool
    let transform: CanvasTransform
    @Binding var lassoPoints: [CGPoint]
    var onLassoSelect: (Set<UUID>) -> Void

    @State private var isDrawing = false

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .contentShape(Rectangle())
                .gesture(isActive ? lassoGesture : nil)
        }
        .overlay {
            if !lassoPoints.isEmpty && lassoPoints.count > 2 {
                let screenPoints = lassoPoints
                Canvas { context, _ in
                    var path = Path()
                    if let first = screenPoints.first {
                        path.move(to: first)
                        for point in screenPoints.dropFirst() {
                            path.addLine(to: point)
                        }
                        path.closeSubpath()
                    }
                    context.stroke(path, with: .color(Brand.aiBadge.opacity(0.4)), lineWidth: 1.5)
                    context.fill(path, with: .color(Brand.aiBadge.opacity(0.04)))
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var lassoGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                if !isDrawing {
                    isDrawing = true
                    lassoPoints = [value.startLocation]
                }
                lassoPoints.append(value.location)
            }
            .onEnded { _ in
                isDrawing = false
                // Compute which objects are inside the lasso
                let worldPoints = lassoPoints.map { transform.screenToWorld($0) }
                let lassoPath = createPath(from: worldPoints)
                onLassoSelect(Set()) // Will be computed by caller
                lassoPoints = []
            }
    }

    private func createPath(from points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}

/// Test if a point is inside a polygon using ray-casting algorithm.
func isPointInsidePolygon(_ point: CGPoint, polygon: [CGPoint]) -> Bool {
    guard polygon.count >= 3 else { return false }
    var inside = false
    var j = polygon.count - 1
    for i in 0..<polygon.count {
        let pi = polygon[i]
        let pj = polygon[j]
        if ((pi.y > point.y) != (pj.y > point.y)) &&
            (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x) {
            inside.toggle()
        }
        j = i
    }
    return inside
}

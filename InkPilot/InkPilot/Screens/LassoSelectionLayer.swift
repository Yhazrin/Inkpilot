import SwiftUI

/// A freeform lasso drawn by finger drag to select objects.
/// The user draws a closed path; objects whose centers fall inside are selected.
struct LassoSelectionLayer: View {
    let isActive: Bool
    let transform: CanvasTransform
    @Binding var lassoPoints: [CGPoint]
    var onLassoComplete: ([CGPoint]) -> Void

    @State private var isDrawing = false

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .contentShape(Rectangle())
                .gesture(isActive ? lassoGesture : nil)
        }
        .overlay {
            if lassoPoints.count > 2 {
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
                    context.stroke(path, with: .color(Brand.aiAccent.opacity(0.4)), lineWidth: 1.5)
                    context.fill(path, with: .color(Brand.aiAccent.opacity(0.04)))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
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
                // Pass points to parent BEFORE clearing
                let points = lassoPoints
                onLassoComplete(points)
                lassoPoints = []
            }
    }
}

extension CGPoint {
    /// Test if this point is inside a polygon using ray-casting algorithm.
    func isInsidePolygon(_ polygon: [CGPoint]) -> Bool {
        guard polygon.count >= 3 else { return false }
        var inside = false
        var j = polygon.count - 1
        for i in 0..<polygon.count {
            let pi = polygon[i]
            let pj = polygon[j]
            if ((pi.y > y) != (pj.y > y)) &&
                (x < (pj.x - pi.x) * (y - pi.y) / (pj.y - pi.y) + pi.x) {
                inside.toggle()
            }
            j = i
        }
        return inside
    }
}

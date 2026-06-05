import SwiftUI

/// A translucent rectangle drawn by finger drag on empty canvas
/// to select multiple objects at once.
struct SelectionMarqueeLayer: View {
    let isActive: Bool
    let transform: CanvasTransform
    @Binding var marqueeStart: CGPoint?
    @Binding var marqueeEnd: CGPoint?
    var onMarqueeSelect: (CGRect) -> Void

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .contentShape(Rectangle())
                .gesture(isActive ? marqueeGesture(in: geo) : nil)
        }
        .accessibilityHidden(true)
        .overlay {
            if let start = marqueeStart, let end = marqueeEnd {
                let rect = marqueeRect(from: start, to: end)
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Brand.aiAccent.opacity(0.6), lineWidth: Brand.selectionStrokeWidth)
                    .background(Brand.aiAccent.opacity(0.06))
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
            }
        }
    }

    private func marqueeGesture(in geo: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                if marqueeStart == nil {
                    marqueeStart = value.startLocation
                }
                marqueeEnd = value.location
            }
            .onEnded { value in
                guard let start = marqueeStart else { return }
                let screenRect = marqueeRect(from: start, to: value.location)
                // Convert screen rect to world rect
                let worldTopLeft = transform.screenToWorld(
                    CGPoint(x: screenRect.minX, y: screenRect.minY)
                )
                let worldBottomRight = transform.screenToWorld(
                    CGPoint(x: screenRect.maxX, y: screenRect.maxY)
                )
                let worldRect = CGRect(
                    x: worldTopLeft.x,
                    y: worldTopLeft.y,
                    width: worldBottomRight.x - worldTopLeft.x,
                    height: worldBottomRight.y - worldTopLeft.y
                )
                onMarqueeSelect(worldRect)
                marqueeStart = nil
                marqueeEnd = nil
            }
    }

    private func marqueeRect(from start: CGPoint, to end: CGPoint) -> CGRect {
        CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
    }
}

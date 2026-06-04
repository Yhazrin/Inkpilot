import SwiftUI
import PencilKit

/// A UIViewRepresentable wrapper around PKCanvasView
/// that provides Apple Pencil and touch drawing on the canvas.
struct PencilKitCanvasRepresentable: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var tool: CanvasTool

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.delegate = context.coordinator
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.maximumZoomScale = 4
        canvas.minimumZoomScale = 1
        canvas.bounces = true
        canvas.alwaysBounceVertical = true
        canvas.alwaysBounceHorizontal = true
        updateTool(on: canvas)
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        updateTool(on: canvas)
        if canvas.drawing != drawing {
            canvas.drawing = drawing
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    private func updateTool(on canvas: PKCanvasView) {
        switch tool {
        case .pen:
            canvas.tool = PKInkingTool(.pen, color: UIColor(Brand.inkPrimary), width: 2)
        case .eraser:
            canvas.tool = PKEraserTool(.bitmap)
        case .lasso, .select:
            canvas.tool = PKLassoTool()
        case .text, .shape, .media:
            // Non-drawing tools — disable PencilKit input
            canvas.tool = PKLassoTool()
        }
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing

        /// How many strokes we've already processed. If the drawing has
        /// more strokes than this, the new ones are candidates for
        /// smoothing.
        private var lastSeenStrokeCount: Int = 0

        /// Re-entrancy guard: when we programmatically replace the
        /// drawing to apply smoothing, the delegate fires again. We
        /// ignore that re-entry.
        private var isApplyingSmoothing = false

        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Re-entry from our own programmatic update — sync the
            // binding (so the view model sees the smoothed version)
            // and bail.
            if isApplyingSmoothing {
                isApplyingSmoothing = false
                drawing = canvasView.drawing
                lastSeenStrokeCount = canvasView.drawing.strokes.count
                return
            }

            let current = canvasView.drawing
            let currentCount = current.strokes.count
            defer { lastSeenStrokeCount = currentCount }

            guard StrokeSmoother.isEnabled,
                  currentCount > lastSeenStrokeCount,
                  currentCount >= 1 else {
                drawing = current
                return
            }

            // Only the newly added strokes are candidates. If the user
            // did multiple strokes between frames (e.g. fast writing),
            // smooth them all.
            let newStrokeStart = lastSeenStrokeCount
            var strokes = current.strokes
            for i in newStrokeStart..<currentCount {
                strokes[i] = StrokeSmoother.smooth(strokes[i])
            }
            let smoothed = PKDrawing(strokes: strokes)

            isApplyingSmoothing = true
            canvasView.drawing = smoothed
            drawing = smoothed
        }
    }
}

#Preview {
    PencilKitCanvasRepresentable(drawing: .constant(PKDrawing()), tool: .pen)
}

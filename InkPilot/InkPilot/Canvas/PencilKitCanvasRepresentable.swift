import SwiftUI
import PencilKit

/// A UIViewRepresentable wrapper around PKCanvasView.
/// Syncs zoom/scroll state with CanvasViewModel.transform so the
/// object layer can stay in the same coordinate space.
struct PencilKitCanvasRepresentable: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var tool: CanvasTool
    var onTransformChange: ((CGFloat, CGSize) -> Void)?

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.delegate = context.coordinator
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.maximumZoomScale = 4
        canvas.minimumZoomScale = 0.25
        canvas.bounces = true
        canvas.alwaysBounceVertical = true
        canvas.alwaysBounceHorizontal = true

        // Observe scroll/zoom changes to sync transform
        canvas.scrollViewDelegate = context.coordinator

        updateTool(on: canvas)
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        updateTool(on: canvas)
        context.coordinator.onTransformChange = onTransformChange
        if canvas.drawing != drawing {
            canvas.drawing = drawing
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing, onTransformChange: onTransformChange)
    }

    private func updateTool(on canvas: PKCanvasView) {
        switch tool {
        case .pen:
            canvas.tool = PKInkingTool(.pen, color: UIColor(Brand.inkPrimary), width: 2)
        case .eraser:
            canvas.tool = PKEraserTool(.bitmap)
        case .select:
            canvas.tool = PKLassoTool()
        case .text, .shape, .media:
            canvas.tool = PKLassoTool()
        }
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate, UIScrollViewDelegate {
        @Binding var drawing: PKDrawing
        var onTransformChange: ((CGFloat, CGSize) -> Void)?

        private var lastSeenStrokeCount: Int = 0
        private var isApplyingSmoothing = false

        init(drawing: Binding<PKDrawing>, onTransformChange: ((CGFloat, CGSize) -> Void)?) {
            _drawing = drawing
            self.onTransformChange = onTransformChange
        }

        // MARK: - PKCanvasViewDelegate

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
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

        // MARK: - UIScrollViewDelegate (zoom + pan sync)

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            notifyTransform(scrollView)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            notifyTransform(scrollView)
        }

        private func notifyTransform(_ scrollView: UIScrollView) {
            let scale = scrollView.zoomScale
            let offset = CGSize(
                width: -scrollView.contentOffset.x,
                height: -scrollView.contentOffset.y
            )
            onTransformChange?(scale, offset)
        }
    }
}

#Preview {
    PencilKitCanvasRepresentable(
        drawing: .constant(PKDrawing()),
        tool: .pen,
        onTransformChange: nil
    )
}

import SwiftUI
import PencilKit

/// A UIViewRepresentable wrapper around PKCanvasView.
/// Uses DrawingToolState for stroke color/width/type.
struct PencilKitCanvasRepresentable: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var tool: CanvasTool
    var drawingToolState: DrawingToolState
    var onTransformChange: ((CGFloat, CGSize) -> Void)?

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.delegate = context.coordinator
        canvas.drawingPolicy = .pencilOnly
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.maximumZoomScale = Brand.maxZoomScale
        canvas.minimumZoomScale = Brand.minZoomScale
        canvas.bounces = true
        canvas.alwaysBounceVertical = true
        canvas.alwaysBounceHorizontal = true
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
            let pkTool = makePKTool()
            canvas.tool = pkTool
        case .eraser:
            switch drawingToolState.eraserMode {
            case .bitmap:
                canvas.tool = PKEraserTool(.bitmap)
            case .vector:
                canvas.tool = PKEraserTool(.vector)
            }
        case .select:
            canvas.tool = PKLassoTool()
        case .text, .shape, .connector, .media:
            canvas.tool = PKLassoTool()
        }
    }

    /// Build a PKInkingTool from the current DrawingToolState.
    private func makePKTool() -> PKInkingTool {
        let uiColor = UIColor(drawingToolState.effectiveColor)
        let width = drawingToolState.width

        switch drawingToolState.selectedKind {
        case .pen:
            return PKInkingTool(.pen, color: uiColor, width: width)
        case .pencil:
            return PKInkingTool(.pencil, color: uiColor, width: width)
        case .highlighter:
            // PencilKit marker is the closest to highlighter
            return PKInkingTool(.marker, color: uiColor, width: width * Brand.highlighterWidthMultiplier)
        case .eraser:
            // Should not reach here — eraser uses PKEraserTool
            return PKInkingTool(.pen, color: uiColor, width: width)
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
        drawingToolState: DrawingToolState(),
        onTransformChange: nil
    )
}

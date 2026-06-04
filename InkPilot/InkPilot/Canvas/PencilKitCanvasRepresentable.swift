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

        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }
    }
}

#Preview {
    PencilKitCanvasRepresentable(drawing: .constant(PKDrawing()), tool: .pen)
}

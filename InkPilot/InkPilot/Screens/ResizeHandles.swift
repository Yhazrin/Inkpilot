import SwiftUI

/// Resize handles that appear on selected objects.
/// Four corner handles for resizing. Caches original size at drag
/// start to prevent acceleration bug.
struct ResizeHandles: View {
    let objectSize: CGSize
    var onResize: (CGSize) -> Void
    var onResizeStart: (() -> Void)?

    private let handleSize: CGFloat = 12
    private let minSize: CGFloat = 40

    /// Cached original size at the start of each corner drag.
    @State private var dragStartSize: CGSize?

    var body: some View {
        ZStack {
            handle(at: .topLeft)
            handle(at: .topRight)
            handle(at: .bottomLeft)
            handle(at: .bottomRight)
        }
        .frame(width: objectSize.width + handleSize * 2,
               height: objectSize.height + handleSize * 2)
    }

    private func handle(at corner: Corner) -> some View {
        Circle()
            .fill(Brand.canvasBase)
            .frame(width: handleSize, height: handleSize)
            .overlay(Circle().strokeBorder(Brand.aiAccent, lineWidth: Brand.selectionStrokeWidth))
            .position(position(for: corner))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Cache original size on first frame
                        if dragStartSize == nil {
                            dragStartSize = objectSize
                            onResizeStart?()
                        }
                        let original = dragStartSize ?? objectSize
                        let newSize = resizedSize(
                            original: original,
                            translation: value.translation,
                            corner: corner
                        )
                        onResize(newSize)
                    }
                    .onEnded { _ in
                        dragStartSize = nil
                    }
            )
            .accessibilityLabel(Text(String(localized: "action.resize")))
    }

    private func position(for corner: Corner) -> CGPoint {
        let w = objectSize.width + handleSize
        let h = objectSize.height + handleSize
        switch corner {
        case .topLeft:     return CGPoint(x: 0, y: 0)
        case .topRight:    return CGPoint(x: w, y: 0)
        case .bottomLeft:  return CGPoint(x: 0, y: h)
        case .bottomRight: return CGPoint(x: w, y: h)
        }
    }

    /// Compute new size from the ORIGINAL size + cumulative translation.
    /// Because we cache `original` at drag start, the result is stable
    /// across frames — no acceleration.
    private func resizedSize(original: CGSize, translation: CGSize, corner: Corner) -> CGSize {
        var newWidth = original.width
        var newHeight = original.height

        switch corner {
        case .topLeft:
            newWidth = max(minSize, original.width - translation.width)
            newHeight = max(minSize, original.height - translation.height)
        case .topRight:
            newWidth = max(minSize, original.width + translation.width)
            newHeight = max(minSize, original.height - translation.height)
        case .bottomLeft:
            newWidth = max(minSize, original.width - translation.width)
            newHeight = max(minSize, original.height + translation.height)
        case .bottomRight:
            newWidth = max(minSize, original.width + translation.width)
            newHeight = max(minSize, original.height + translation.height)
        }

        return CGSize(width: newWidth, height: newHeight)
    }

    private enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight
    }
}

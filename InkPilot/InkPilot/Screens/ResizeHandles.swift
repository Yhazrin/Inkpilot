import SwiftUI

/// Resize handles that appear on selected objects.
/// Four corner handles + four edge handles for resizing.
struct ResizeHandles: View {
    let objectSize: CGSize
    var onResize: (CGSize) -> Void

    private let handleSize: CGFloat = 12
    private let minSize: CGFloat = 40

    var body: some View {
        ZStack {
            // Corner handles
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
            .fill(.white)
            .frame(width: handleSize, height: handleSize)
            .overlay(Circle().strokeBorder(Brand.aiBadge, lineWidth: 1.5))
            .position(position(for: corner))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let newSize = resizedSize(from: value.translation, corner: corner)
                        onResize(newSize)
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

    private func resizedSize(from translation: CGSize, corner: Corner) -> CGSize {
        var newWidth = objectSize.width
        var newHeight = objectSize.height

        switch corner {
        case .topLeft:
            newWidth = max(minSize, objectSize.width - translation.width)
            newHeight = max(minSize, objectSize.height - translation.height)
        case .topRight:
            newWidth = max(minSize, objectSize.width + translation.width)
            newHeight = max(minSize, objectSize.height - translation.height)
        case .bottomLeft:
            newWidth = max(minSize, objectSize.width - translation.width)
            newHeight = max(minSize, objectSize.height + translation.height)
        case .bottomRight:
            newWidth = max(minSize, objectSize.width + translation.width)
            newHeight = max(minSize, objectSize.height + translation.height)
        }

        return CGSize(width: newWidth, height: newHeight)
    }

    private enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight
    }
}

import SwiftUI

/// A floating palette for selecting shape types and mind map nodes.
struct ShapePalette: View {
    var onSelect: (CanvasShapeKind) -> Void
    var onMindNode: () -> Void
    var onClose: () -> Void

    private let shapes: [(CanvasShapeKind, String, String)] = [
        (.rectangle, "rectangle", "palette.shape.rectangle"),
        (.roundedRectangle, "rectangle.roundedtop", "palette.shape.roundedRect"),
        (.ellipse, "circle", "palette.shape.ellipse"),
        (.diamond, "diamond", "palette.shape.diamond"),
        (.line, "line.diagonal", "palette.shape.line"),
        (.arrow, "arrow.right", "palette.shape.arrow"),
    ]

    var body: some View {
        GlassCapsule {
            ForEach(shapes, id: \.0) { kind, icon, labelKey in
                Button {
                    onSelect(kind)
                } label: {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Brand.inkPrimary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel(Text(LocalizedStringKey(labelKey)))
            }

            Divider().frame(height: 20)

            // Mind map node
            Button {
                onMindNode()
            } label: {
                Image(systemName: "bubble.left.and.text.bubble.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Brand.aiAccent)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text(String(localized: "palette.mindNode")))

            Divider().frame(height: 20)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Brand.inkSecondary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text(String(localized: "palette.close")))
        }
    }
}

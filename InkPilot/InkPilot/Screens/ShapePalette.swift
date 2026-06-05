import SwiftUI

/// A floating palette for selecting shape types and mind map nodes.
struct ShapePalette: View {

    // MARK: - Properties
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
                        .font(Brand.iconFont)
                        .foregroundStyle(Brand.inkPrimary)
                        .frame(width: Brand.touchTarget, height: Brand.touchTarget)
                }
                .accessibilityLabel(Text(LocalizedStringKey(labelKey)))
            }

            Divider().frame(height: Brand.dividerHeight)

            // Mind map node
            Button {
                onMindNode()
            } label: {
                Image(systemName: "bubble.left.and.text.bubble.right")
                    .font(Brand.iconFont)
                    .foregroundStyle(Brand.aiAccent)
                    .frame(width: Brand.touchTarget, height: Brand.touchTarget)
            }
            .accessibilityLabel(Text(String(localized: "palette.mindNode")))

            Divider().frame(height: Brand.dividerHeight)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(Brand.paletteFont.weight(.semibold))
                    .foregroundStyle(Brand.inkSecondary)
                    .frame(width: Brand.touchTarget, height: Brand.touchTarget)
            }
            .accessibilityLabel(Text(String(localized: "palette.close")))
        }
    }
}

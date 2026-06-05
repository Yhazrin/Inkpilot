import SwiftUI

/// A floating glass capsule used for toolbars and prompt bars.
/// Compact, translucent, with rounded-pill shape.
struct GlassCapsule<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        HStack(spacing: Brand.spacingS) {
            content()
        }
        .padding(.horizontal, Brand.spacingM)
        .padding(.vertical, Brand.spacingS)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
        }
        .overlay {
            Capsule()
                .strokeBorder(Brand.glassBorder, lineWidth: Brand.glassBorderWidth)
        }
        .shadow(color: Brand.glassShadow, radius: Brand.shadowRadius, y: Brand.shadowY)
    }
}

#Preview {
    GlassCapsule {
        Image(systemName: "pencil")
        Image(systemName: "eraser")
        Image(systemName: "lasso")
    }
    .padding(Brand.spacingXL)
    .background(Brand.canvasBase)
}

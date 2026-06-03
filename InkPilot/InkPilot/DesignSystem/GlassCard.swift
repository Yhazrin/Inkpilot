import SwiftUI

/// A rounded glass card with translucent material, soft border, and subtle shadow.
/// Used for canvas content cards, accepted AI suggestions, and hero content.
struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let content: () -> Content

    init(
        cornerRadius: CGFloat = Brand.cornerM,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        content()
            .padding(Brand.spacingM)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Brand.glassBorder, lineWidth: 0.5)
            }
            .shadow(color: Brand.glassShadow, radius: Brand.shadowRadius, y: Brand.shadowY)
    }
}

#Preview {
    GlassCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target Users")
                .font(Brand.titleFont)
            Text("Students, product managers, researchers")
                .font(Brand.bodyFont)
                .foregroundStyle(Brand.inkSecondary)
        }
    }
    .padding(40)
    .background(Brand.canvasBase)
}

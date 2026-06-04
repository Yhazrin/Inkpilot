import SwiftUI

/// A rounded glass card with translucent material, a subtle top-highlight
/// hairline, and a soft depth shadow. The card lets the canvas color
/// bleed through via the material so it feels like it belongs on the page
/// rather than sitting on top of it.
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
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Brand.glassHighlight,
                                Brand.glassBorder
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: Brand.hairline
                    )
            }
            .shadow(
                color: Brand.glassShadowSoft,
                radius: 24,
                y: 8
            )
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

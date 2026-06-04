import SwiftUI

/// A compact floating glass panel with rounded corners and a subtle
/// top-highlight hairline. Uses a slightly stronger material than
/// `GlassCard` so panel content stays readable when stacked over the canvas.
struct FloatingPanel<Content: View>: View {
    let cornerRadius: CGFloat
    let content: () -> Content

    init(
        cornerRadius: CGFloat = Brand.cornerL,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacingS) {
            content()
        }
        .padding(Brand.spacingM)
        .frame(minWidth: 180)
        .background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.regularMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Brand.glassHighlight, Brand.glassBorder],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: Brand.hairline
                )
        }
        .shadow(
            color: Brand.glassShadow,
            radius: Brand.shadowRadius,
            y: Brand.shadowY
        )
    }
}

#Preview {
    FloatingPanel {
        Text("AI Pilot")
            .font(Brand.titleFont)
        Text("3 suggestions")
            .font(Brand.captionFont)
            .foregroundStyle(Brand.inkSecondary)
    }
    .padding(40)
    .background(Brand.canvasBase)
}

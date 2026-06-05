import SwiftUI

/// A compact floating glass panel with rounded corners.
/// Used for the AI Pilot sidebar panel and other contextual overlays.
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
        .frame(minWidth: Brand.floatingPanelMinWidth)
        .background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.regularMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Brand.glassBorder, lineWidth: Brand.glassBorderWidth)
        }
        .shadow(color: Brand.glassShadow, radius: Brand.shadowRadius, y: Brand.shadowY)
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
    .padding(Brand.spacingXL)
    .background(Brand.canvasBase)
}

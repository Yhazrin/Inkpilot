import SwiftUI

/// The bottom floating prompt capsule.
/// Allows the user to type a prompt or tap to trigger a mock AI suggestion.
struct FloatingPromptCapsule: View {
    @Binding var promptText: String
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: Brand.spacingS) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Brand.aiBadge)

            TextField(
                String(localized: "canvas.prompt.placeholder"),
                text: $promptText
            )
            .font(Brand.bodyFont)
            .foregroundStyle(Brand.inkPrimary)
            .onSubmit {
                onSubmit()
            }

            if !promptText.isEmpty {
                Button(action: onSubmit) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Brand.aiBadge)
                }
                .accessibilityLabel(Text(String(localized: "canvas.prompt.submit")))
            }
        }
        .padding(.horizontal, Brand.spacingM)
        .padding(.vertical, 12)
        .frame(maxWidth: 480)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
        }
        .overlay {
            Capsule()
                .strokeBorder(Brand.glassBorder, lineWidth: 0.5)
        }
        .shadow(color: Brand.glassShadow, radius: Brand.shadowRadius, y: Brand.shadowY)
        .accessibilityLabel(Text(String(localized: "canvas.prompt.accessibility")))
    }
}

#Preview {
    FloatingPromptCapsule(promptText: .constant(""), onSubmit: {})
        .padding(40)
        .background(Brand.canvasBase)
}

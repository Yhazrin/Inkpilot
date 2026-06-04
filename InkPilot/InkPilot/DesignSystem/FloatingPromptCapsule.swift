import SwiftUI

/// The bottom floating prompt capsule.
/// Shows thinking state when AI is processing.
struct FloatingPromptCapsule: View {
    @Binding var promptText: String
    var isThinking: Bool = false
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: Brand.spacingS) {
            if isThinking {
                ProgressView()
                    .scaleEffect(0.8)
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Brand.aiAccent)
            }

            TextField(
                isThinking
                    ? String(localized: "canvas.ai.thinking")
                    : String(localized: "canvas.prompt.placeholder"),
                text: $promptText
            )
            .font(Brand.bodyFont)
            .foregroundStyle(Brand.inkPrimary)
            .disabled(isThinking)
            .onSubmit {
                guard !isThinking else { return }
                onSubmit()
            }

            if !promptText.isEmpty && !isThinking {
                Button(action: onSubmit) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Brand.aiAccent)
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
                .strokeBorder(
                    isThinking ? Brand.aiBadge.opacity(0.4) : Brand.glassBorder,
                    lineWidth: isThinking ? 1 : 0.5
                )
        }
        .shadow(color: Brand.glassShadow, radius: Brand.shadowRadius, y: Brand.shadowY)
        .accessibilityLabel(Text(String(localized: "canvas.prompt.accessibility")))
    }
}

#Preview("Normal") {
    FloatingPromptCapsule(promptText: .constant(""), onSubmit: {})
        .padding(40)
        .background(Brand.canvasBase)
}

#Preview("Thinking") {
    FloatingPromptCapsule(promptText: .constant(""), isThinking: true, onSubmit: {})
        .padding(40)
        .background(Brand.canvasBase)
}

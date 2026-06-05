import SwiftUI

/// The bottom floating prompt capsule.
/// Shows thinking state when AI is processing.
struct FloatingPromptCapsule: View {

    // MARK: - Properties
    @Binding var promptText: String
    var isThinking: Bool = false
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: Brand.spacingS) {
            if isThinking {
                ProgressView()
                    .scaleEffect(0.8)
                    .frame(width: Brand.spinnerSize, height: Brand.spinnerSize)
            } else {
                Image(systemName: "sparkles")
                    .font(Brand.paletteFont)
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
                        .font(.system(size: Brand.submitIconSize))
                        .foregroundStyle(Brand.aiAccent)
                }
                .accessibilityLabel(Text(String(localized: "canvas.prompt.submit")))
            }
        }
        .padding(.horizontal, Brand.spacingM)
        .padding(.vertical, Brand.promptPaddingV)
        .frame(maxWidth: Brand.promptMaxWidth)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
        }
        .overlay {
            Capsule()
                .strokeBorder(
                    isThinking ? Brand.aiBadge.opacity(Brand.subtleAccentOpacity) : Brand.glassBorder,
                    lineWidth: isThinking ? Brand.selectionStrokeWidth : Brand.glassBorderWidth
                )
        }
        .shadow(color: Brand.glassShadow, radius: Brand.shadowRadius, y: Brand.shadowY)
        .accessibilityLabel(Text(String(localized: "canvas.prompt.accessibility")))
    }
}

#Preview("Normal") {
    FloatingPromptCapsule(promptText: .constant(""), onSubmit: {})
        .padding(Brand.spacingXL)
        .background(Brand.canvasBase)
}

#Preview("Thinking") {
    FloatingPromptCapsule(promptText: .constant(""), isThinking: true, onSubmit: {})
        .padding(Brand.spacingXL)
        .background(Brand.canvasBase)
}

import SwiftUI

/// The top floating tool capsule for the canvas.
/// Provides Pen, Eraser, Lasso, and a quiet AI trigger.
/// Each tool has a 44x44 tap target with a subtle "depression" on
/// selection to feel like an iPadOS floating tool palette.
struct FloatingToolbar: View {
    @Binding var selectedTool: CanvasTool
    var onAITap: () -> Void

    var body: some View {
        GlassCapsule {
            toolButton(tool: .pen, icon: "pencil", label: String(localized: "tool.pen"))
            toolButton(tool: .eraser, icon: "eraser.fill", label: String(localized: "tool.eraser"))
            toolButton(tool: .lasso, icon: "lasso", label: String(localized: "tool.lasso"))

            Divider()
                .frame(height: 20)
                .overlay(Brand.glassBorder)

            Button(action: onAITap) {
                ZStack {
                    // Very subtle glow on the AI trigger.
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Brand.aiMark.opacity(0.20), .clear],
                                center: .center,
                                startRadius: 2,
                                endRadius: 18
                            )
                        )
                        .frame(width: 30, height: 30)

                    Image(systemName: "sparkle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Brand.aiBadge)
                }
                .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text(String(localized: "tool.ai")))
        }
    }

    private func toolButton(tool: CanvasTool, icon: String, label: String) -> some View {
        Button {
            withAnimation(Motion.crisp) {
                selectedTool = tool
            }
        } label: {
            ZStack {
                // Subtle glass depression for the selected tool — inner
                // shadow + soft inkPrimary tint reads as a depressed pill.
                if selectedTool == tool {
                    Capsule()
                        .fill(Brand.inkPrimary.opacity(0.06))
                        .overlay {
                            Capsule()
                                .strokeBorder(Brand.glassBorder, lineWidth: Brand.hairline)
                        }
                        .frame(width: 36, height: 30)
                        .transition(.opacity)
                }

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(selectedTool == tool ? Brand.inkPrimary : Brand.inkSecondary)
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .accessibilityLabel(Text(label))
    }
}

#Preview {
    FloatingToolbar(selectedTool: .constant(.pen), onAITap: {})
        .padding(40)
        .background(Brand.canvasBase)
}

import SwiftUI

/// The top floating tool capsule for the canvas.
/// Provides Pen, Eraser, Lasso (placeholder), and AI trigger.
struct FloatingToolbar: View {
    @Binding var selectedTool: CanvasTool
    var onAITap: () -> Void

    var body: some View {
        GlassCapsule {
            toolButton(tool: .pen, icon: "pencil", label: String(localized: "tool.pen"))
            toolButton(tool: .eraser, icon: "eraser", label: String(localized: "tool.eraser"))
            toolButton(tool: .lasso, icon: "lasso", label: String(localized: "tool.lasso"))

            Divider()
                .frame(height: 20)

            Button(action: onAITap) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Brand.aiBadge)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text(String(localized: "tool.ai")))
        }
    }

    private func toolButton(tool: CanvasTool, icon: String, label: String) -> some View {
        Button {
            selectedTool = tool
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(selectedTool == tool ? Brand.inkPrimary : Brand.inkSecondary)
                .frame(width: 44, height: 44)
                .background {
                    if selectedTool == tool {
                        Capsule()
                            .fill(Brand.inkPrimary.opacity(0.08))
                    }
                }
        }
        .accessibilityLabel(Text(label))
    }
}

#Preview {
    FloatingToolbar(selectedTool: .constant(.pen), onAITap: {})
        .padding(40)
        .background(Brand.canvasBase)
}

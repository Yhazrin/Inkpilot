import SwiftUI

/// The top floating tool capsule for the canvas.
struct FloatingToolbar: View {
    @Binding var selectedTool: CanvasTool
    var canUndo: Bool
    var canRedo: Bool
    var onUndo: () -> Void
    var onRedo: () -> Void
    var onAITap: () -> Void
    var onShapeTap: () -> Void
    var onMediaTap: () -> Void

    var body: some View {
        GlassCapsule {
            toolButton(tool: .pen, icon: "pencil", label: String(localized: "tool.pen"))
            toolButton(tool: .eraser, icon: "eraser", label: String(localized: "tool.eraser"))
            toolButton(tool: .select, icon: "hand.point.up.left", label: String(localized: "tool.select"))
            toolButton(tool: .text, icon: "textformat", label: String(localized: "tool.text"))

            shapeButton
            connectorButton
            mediaButton

            Divider()
                .frame(height: Brand.dividerHeight)

            // Undo / Redo
            Button(action: onUndo) {
                Image(systemName: "arrow.uturn.backward")
                    .font(Brand.iconFont)
                    .foregroundStyle(canUndo ? Brand.inkPrimary : Brand.inkSecondary.opacity(0.3))
                    .frame(width: Brand.touchTarget, height: Brand.touchTarget)
            }
            .disabled(!canUndo)
            .accessibilityLabel(Text(String(localized: "action.undo")))

            Button(action: onRedo) {
                Image(systemName: "arrow.uturn.forward")
                    .font(Brand.iconFont)
                    .foregroundStyle(canRedo ? Brand.inkPrimary : Brand.inkSecondary.opacity(0.3))
                    .frame(width: Brand.touchTarget, height: Brand.touchTarget)
            }
            .disabled(!canRedo)
            .accessibilityLabel(Text(String(localized: "action.redo")))

            Divider()
                .frame(height: Brand.dividerHeight)

            Button(action: onAITap) {
                AIToolButton()
            }
            .accessibilityLabel(Text(String(localized: "tool.ai")))
        }
    }

    // MARK: - Shape Button (with palette toggle)

    private var shapeButton: some View {
        Button {
            selectedTool = .shape
            onShapeTap()
        } label: {
            Image(systemName: "square.on.circle")
                .font(Brand.iconFont)
                .foregroundStyle(selectedTool == .shape ? Brand.inkPrimary : Brand.inkSecondary)
                .frame(width: Brand.touchTarget, height: Brand.touchTarget)
                .background {
                    if selectedTool == .shape {
                        Capsule().fill(Brand.inkPrimary.opacity(0.08))
                    }
                }
        }
        .accessibilityLabel(Text(String(localized: "tool.shape")))
    }

    // MARK: - Connector Button

    private var connectorButton: some View {
        Button {
            selectedTool = .connector
        } label: {
            Image(systemName: "arrow.triangle.branch")
                .font(Brand.iconFont)
                .foregroundStyle(selectedTool == .connector ? Brand.inkPrimary : Brand.inkSecondary)
                .frame(width: Brand.touchTarget, height: Brand.touchTarget)
                .background {
                    if selectedTool == .connector {
                        Capsule().fill(Brand.inkPrimary.opacity(0.08))
                    }
                }
        }
        .accessibilityLabel(Text(String(localized: "tool.connector")))
    }

    // MARK: - Media Button (with palette toggle)

    private var mediaButton: some View {
        Button {
            selectedTool = .media
            onMediaTap()
        } label: {
            Image(systemName: "photo.on.rectangle")
                .font(Brand.iconFont)
                .foregroundStyle(selectedTool == .media ? Brand.inkPrimary : Brand.inkSecondary)
                .frame(width: Brand.touchTarget, height: Brand.touchTarget)
                .background {
                    if selectedTool == .media {
                        Capsule().fill(Brand.inkPrimary.opacity(0.08))
                    }
                }
        }
        .accessibilityLabel(Text(String(localized: "tool.media")))
    }

    // MARK: - Generic Tool Button

    private func toolButton(tool: CanvasTool, icon: String, label: String) -> some View {
        Button {
            selectedTool = tool
        } label: {
            Image(systemName: icon)
                .font(Brand.iconFont)
                .foregroundStyle(selectedTool == tool ? Brand.inkPrimary : Brand.inkSecondary)
                .frame(width: Brand.touchTarget, height: Brand.touchTarget)
                .background {
                    if selectedTool == tool {
                        Capsule().fill(Brand.inkPrimary.opacity(0.08))
                    }
                }
        }
        .accessibilityLabel(Text(label))
    }
}

// MARK: - AI Tool Button with subtle pulse

private struct AIToolButton: View {
    @State private var isPulsing = false

    var body: some View {
        Image(systemName: "sparkles")
            .font(Brand.iconFont)
            .foregroundStyle(Brand.aiAccent)
            .frame(width: Brand.touchTarget, height: Brand.touchTarget)
            .scaleEffect(isPulsing ? 1.08 : 1.0)
            .opacity(isPulsing ? 1.0 : 0.85)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

#Preview {
    FloatingToolbar(selectedTool: .constant(.pen), canUndo: true, canRedo: false, onUndo: {}, onRedo: {}, onAITap: {}, onShapeTap: {}, onMediaTap: {})
        .padding(Brand.spacingXL)
        .background(Brand.canvasBase)
}

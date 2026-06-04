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
                .frame(height: 20)

            // Undo / Redo
            Button(action: onUndo) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(canUndo ? Brand.inkPrimary : Brand.inkSecondary.opacity(0.3))
                    .frame(width: 44, height: 44)
            }
            .disabled(!canUndo)
            .accessibilityLabel(Text(String(localized: "action.undo")))

            Button(action: onRedo) {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(canRedo ? Brand.inkPrimary : Brand.inkSecondary.opacity(0.3))
                    .frame(width: 44, height: 44)
            }
            .disabled(!canRedo)
            .accessibilityLabel(Text(String(localized: "action.redo")))

            Divider()
                .frame(height: 20)

            Button(action: onAITap) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Brand.aiAccent)
                    .frame(width: 44, height: 44)
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
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(selectedTool == .shape ? Brand.inkPrimary : Brand.inkSecondary)
                .frame(width: 44, height: 44)
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
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(selectedTool == .connector ? Brand.inkPrimary : Brand.inkSecondary)
                .frame(width: 44, height: 44)
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
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(selectedTool == .media ? Brand.inkPrimary : Brand.inkSecondary)
                .frame(width: 44, height: 44)
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
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(selectedTool == tool ? Brand.inkPrimary : Brand.inkSecondary)
                .frame(width: 44, height: 44)
                .background {
                    if selectedTool == tool {
                        Capsule().fill(Brand.inkPrimary.opacity(0.08))
                    }
                }
        }
        .accessibilityLabel(Text(label))
    }
}

#Preview {
    FloatingToolbar(selectedTool: .constant(.pen), canUndo: true, canRedo: false, onUndo: {}, onRedo: {}, onAITap: {}, onShapeTap: {}, onMediaTap: {})
        .padding(40)
        .background(Brand.canvasBase)
}

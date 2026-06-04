import SwiftUI

/// The top floating tool capsule for the canvas.
///
/// Provides Pen, Eraser, Lasso (placeholder), and AI trigger.
///
/// Native motion language:
///   • 44×44 tap targets stay.
///   • The selected-state highlight is a single capsule in its own
///     `matchedGeometryEffect` group. It *slides* between the
///     currently-selected tool's button using the morph spring — one
///     continuous surface, not a hard per-button highlight.
///   • The AI button uses a small symbol effect so the icon feels
///     alive without being noisy.
///   • A subtle sensory feedback fires on tool change.
struct FloatingToolbar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var selectedCapsule

    @Binding var selectedTool: CanvasTool
    var onAITap: () -> Void
    @State private var aiBounceTrigger: Int = 0

    var body: some View {
        GlassCapsule {
            toolButton(tool: .pen, icon: "pencil", label: String(localized: "tool.pen"))
            toolButton(tool: .eraser, icon: "eraser.fill", label: String(localized: "tool.eraser"))
            toolButton(tool: .lasso, icon: "lasso", label: String(localized: "tool.lasso"))

            Divider()
                .frame(height: 20)
                .overlay(Brand.glassBorder)

            aiButton
        }
    }

    // MARK: - Tool Button

    private func toolButton(tool: CanvasTool, icon: String, label: String) -> some View {
        Button {
            guard selectedTool != tool else { return }
            withAnimation(SemanticMotion.respecting(SemanticMotion.morph, reduceMotion: reduceMotion)) {
                selectedTool = tool
            }
        } label: {
            ZStack {
                // The capsule is a sibling in the matched geometry group
                // — it sits in front of *whichever* button is selected
                // and slides to it.
                if selectedTool == tool {
                    Capsule(style: .continuous)
                        .fill(Brand.inkPrimary.opacity(0.06))
                        .overlay {
                            Capsule(style: .continuous)
                                .strokeBorder(Brand.glassBorder, lineWidth: 0.5)
                        }
                        .frame(width: 36, height: 30)
                        .matchedGeometryEffect(id: "selectedCapsule", in: selectedCapsule)
                }

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(selectedTool == tool ? Brand.inkPrimary : Brand.inkSecondary)
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .accessibilityLabel(Text(label))
        .accessibilityAddTraits(selectedTool == tool ? .isSelected : [])
    }

    // MARK: - AI Button

    private var aiButton: some View {
        Button(action: {
            aiBounceTrigger &+= 1
            onAITap()
        }) {
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Brand.aiBadge)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
                // Soft, single bounce on tap. Skipped under Reduce Motion.
                .modifier(AIBounceSymbolEffect(
                    reduceMotion: reduceMotion,
                    trigger: aiBounceTrigger
                ))
        }
        .accessibilityLabel(Text(String(localized: "tool.ai")))
    }
}

// MARK: - Symbol effect modifier

/// Wraps `.symbolEffect(.bounce, value:)` so we can opt out under
/// Reduce Motion. iOS 17+ only; iPadOS deployment target is 17.
private struct AIBounceSymbolEffect: ViewModifier {
    let reduceMotion: Bool
    let trigger: Int

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content
                .symbolEffect(.bounce, value: trigger)
        }
    }
}

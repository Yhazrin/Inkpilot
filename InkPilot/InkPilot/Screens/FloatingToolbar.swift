import SwiftUI

/// The top floating tool capsule for the canvas.
///
/// Native motion language:
///   • 44×44 tap targets stay.
///   • The selected-state highlight is a single capsule in its own
///     `matchedGeometryEffect` group. It *slides* between the
///     currently-selected tool's button — one continuous surface, not
///     a hard per-button highlight.
///   • The AI button uses a soft `symbolEffect(.bounce)` on tap, which
///     we suppress under Reduce Motion.
///   • No strong blue highlight, no heavy pill background — a quiet
///     grey tint that does not dominate the canvas.
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
            withAnimation(
                MotionTokens.respecting(MotionTokens.morph, reduceMotion: reduceMotion)
            ) {
                selectedTool = tool
            }
        } label: {
            ZStack {
                // The capsule sits in the matched geometry group — it
                // slides to whichever button is selected. We render it
                // inside every button's ZStack but only one is in the
                // view tree at a time.
                if selectedTool == tool {
                    Capsule(style: .continuous)
                        .fill(Brand.inkPrimary.opacity(0.05))
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
        Button {
            aiBounceTrigger &+= 1
            onAITap()
        } label: {
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Brand.aiBadge)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
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
/// Reduce Motion.
private struct AIBounceSymbolEffect: ViewModifier {
    let reduceMotion: Bool
    let trigger: Int

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.symbolEffect(.bounce, value: trigger)
        }
    }
}

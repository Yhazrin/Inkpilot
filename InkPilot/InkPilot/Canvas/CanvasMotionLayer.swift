import SwiftUI

/// A subtle "scan aura" that appears at the suggestion anchor when AI
/// is triggered. Intentionally non-sci-fi: a soft, slow radial pulse
/// that feels like the canvas is paying attention, not like a radar.
///
/// Renders nothing when `anchor` is nil. Honors Reduce Motion by holding
/// the aura at a static opacity / scale.
struct CanvasMotionLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let anchor: CGPoint?
    /// Whether the AI is currently "thinking" (true between request and
    /// arrival of suggestion). Drives the scan pulse.
    let isThinking: Bool

    var body: some View {
        ZStack {
            if let anchor, isThinking || !reduceMotion {
                aura(at: anchor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    // MARK: - Aura

    @ViewBuilder
    private func aura(at point: CGPoint) -> some View {
        // Two soft, slow-pulsing rings + a static center dot.
        // The center dot is always there (Reduce Motion still wants a
        // visible "the AI is here" cue). The rings are the part that
        // gets gated off under Reduce Motion.
        ZStack {
            // Outer breathing ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Brand.aiGlow.opacity(0.55),
                            Brand.aiGlow.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 90
                    )
                )
                .frame(width: 180, height: 180)
                .opacity(reduceMotion ? 0.0 : 1.0)
                .scaleEffect(reduceMotion ? 0.6 : 1.0)
                .modifier(ContinuousBreath(
                    reduceMotion: reduceMotion,
                    minScale: 0.9,
                    maxScale: 1.1,
                    minOpacity: 0.5,
                    maxOpacity: 1.0
                ))

            // Inner tighter ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Brand.aiBadge.opacity(0.18),
                            Brand.aiBadge.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 36
                    )
                )
                .frame(width: 72, height: 72)
                .modifier(ContinuousBreath(
                    reduceMotion: reduceMotion,
                    minScale: 0.85,
                    maxScale: 1.15,
                    minOpacity: 0.6,
                    maxOpacity: 1.0,
                    phaseShift: 0.5 as Double
                ))

            // Quiet center dot — the "AI is here" mark
            Circle()
                .fill(Brand.aiBadge.opacity(0.35))
                .frame(width: 6, height: 6)
        }
        .position(point)
    }
}

// MARK: - Continuous breath helper

/// Drives an indefinite subtle scale + opacity oscillation.
/// Under Reduce Motion, the breath is frozen at the "rest" frame.
private struct ContinuousBreath: ViewModifier {
    let reduceMotion: Bool
    let minScale: CGFloat
    let maxScale: CGFloat
    let minOpacity: CGFloat
    let maxOpacity: CGFloat
    /// 0…1 phase offset so multiple rings don't pulse in lockstep.
    var phaseShift: Double = 0

    @State private var on: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(on ? maxScale : minScale)
            .opacity(on ? maxOpacity : minOpacity)
            .onAppear {
                guard !reduceMotion else { return }
                // Kick the breath off so the ring scales up + back down
                // forever. The animation is `repeating` via toggling
                // on a timer, which is the only reliable way on iPadOS
                // to drive a true two-state breath without `phaseAnimator`.
                breath()
            }
    }

    private func breath() {
        let duration = 1.6
        withAnimation(.easeInOut(duration: duration).delay(phaseShift * duration)) {
            on.toggle()
        }
        // Schedule the next toggle so the breath keeps going.
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [self] in
            breath()
        }
    }
}

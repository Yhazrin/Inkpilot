import SwiftUI

/// A thin, non-interactive visual layer that sits above the PencilKit
/// surface and below the floating chrome. It renders three calm
/// effects, all driven by `CanvasViewModel` state and all gated on
/// accessibility settings.
///
/// Effects:
///   1. **Scan aura** — soft, slow breath at the suggestion anchor
///      while AI is thinking (`isThinking == true`).
///   2. **Source glow** — a quieter breath at the suggestion anchor
///      while a ghost suggestion is on screen.
///   3. **Materialization trace** — a brief, very low-opacity ring
///      that pulses out from the source anchor when cards are being
///      accepted. Cleared by the view after `anchorMaterializeDelay`.
///
/// Requirements (per spec):
///   - `allowsHitTesting(false)` so it never steals touches.
///   - `accessibilityHidden(true)` so VoiceOver ignores it.
///   - All continuous animations honor `accessibilityReduceMotion`.
///   - No recursive `DispatchQueue` loops. Continuous effects use
///     `TimelineView(.animation)`, which the system drives and tears
///     down automatically. One-shot effects use state + `withAnimation`
///     triggered by `.onChange`.
struct CanvasMotionLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The current suggestion anchor in screen space, if any.
    let anchor: CGPoint?

    /// Whether AI is currently thinking (drives the scan aura).
    let isThinking: Bool

    /// Whether a ghost suggestion is on screen (drives the source glow).
    let hasGhost: Bool

    /// Increment this from the view when accepted cards are inserted.
    /// Each change briefly pulses the materialization trace.
    let materializationCount: Int

    var body: some View {
        ZStack {
            if let anchor, !reduceMotion {
                if isThinking {
                    ScanAura(center: anchor)
                } else if hasGhost {
                    SourceGlow(center: anchor)
                }

                if materializationCount > 0 {
                    MaterializationTrace(
                        center: anchor,
                        pulse: materializationCount
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Scan aura

/// A soft, slow, low-opacity breath around the suggestion anchor while
/// AI is "thinking". Implemented as a `TimelineView(.animation)` so
/// the system drives the timeline — no recursive `DispatchQueue` loops,
/// no manual PhaseAnimator ambiguity. A simple `sin` wave on the
/// current time gives a calm, endless in/out breath at 1.6s period.
private struct ScanAura: View {
    let center: CGPoint

    var body: some View {
        let ring = Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Brand.aiGlow.opacity(0.6),
                        Brand.aiGlow.opacity(0.0)
                    ],
                    center: .center,
                    startRadius: 4,
                    endRadius: 80
                )
            )
            .frame(width: 160, height: 160)

        let pip = Circle()
            .fill(Brand.aiBadge.opacity(0.35))
            .frame(width: 6, height: 6)

        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let phase = breathPhase(
                at: context.date,
                period: MotionTokens.scanDuration
            )
            ZStack {
                ring
                    .scaleEffect(0.9 + 0.1 * phase)
                    .opacity(0.55 - 0.25 * phase)
                pip
            }
            .position(center)
        }
    }
}

// MARK: - Source glow

/// A quieter, smaller, steadier glow at the suggestion anchor while a
/// ghost suggestion is on screen. Tells the user "this is where the
/// suggestion came from" without competing with the ghost card.
private struct SourceGlow: View {
    let center: CGPoint

    var body: some View {
        let halo = Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Brand.aiGlow.opacity(0.35),
                        Brand.aiGlow.opacity(0.0)
                    ],
                    center: .center,
                    startRadius: 2,
                    endRadius: 50
                )
            )
            .frame(width: 100, height: 100)

        let pip = Circle()
            .fill(Brand.aiBadge.opacity(0.5))
            .frame(width: 4, height: 4)

        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let phase = breathPhase(
                at: context.date,
                period: MotionTokens.scanDuration
            )
            ZStack {
                halo.opacity(0.45 - 0.1 * phase)
                pip
            }
            .position(center)
        }
    }
}

// MARK: - Materialization trace

/// A brief, very low-opacity ring that pulses out from the source
/// anchor when accepted cards are inserted.
///
/// Driven by a `@State` value (real state) that the view resets to 0
/// and animates to 1 via `withAnimation`. The view re-fires this
/// every time `pulse` changes, so each acceptance produces a visible
/// pulse.
private struct MaterializationTrace: View {
    let center: CGPoint
    let pulse: Int

    @State private var progress: Double = 0

    var body: some View {
        Circle()
            .strokeBorder(Brand.aiGlow, lineWidth: 1)
            .frame(width: 120, height: 120)
            .scaleEffect(0.6 + 0.6 * progress)
            .opacity(0.4 - 0.35 * progress)
            .position(center)
            .onAppear { runPulse() }
            .onChange(of: pulse) { _, _ in runPulse() }
    }

    private func runPulse() {
        progress = 0
        withAnimation(MotionTokens.morph) {
            progress = 1
        }
    }
}

// MARK: - Helpers

/// A 0…1 breath phase derived from a `Date` and a period. The
/// waveform is `0.5 - 0.5*cos(2π·t/period)` so it eases smoothly
/// from 0 to 1 and back, with no discontinuities.
private func breathPhase(at date: Date, period: TimeInterval) -> Double {
    let t = date.timeIntervalSinceReferenceDate
    let angle = (2.0 * .pi * t) / period
    return 0.5 - 0.5 * cos(angle)
}

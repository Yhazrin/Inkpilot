import SwiftUI

/// A non-interactive visual layer above PencilKit, below chrome.
/// Renders scan aura (thinking), source glow (ghost on screen),
/// and materialization trace (cards accepted).
struct CanvasMotionLayer: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let anchor: CGPoint?
    let isThinking: Bool
    let hasGhost: Bool
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
                    MaterializationTrace(center: anchor, pulse: materializationCount)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Scan Aura

private struct ScanAura: View {
    let center: CGPoint

    var body: some View {
        let ring = Circle()
            .fill(RadialGradient(
                colors: [Brand.aiGlow.opacity(0.6), Brand.aiGlow.opacity(0.0)],
                center: .center, startRadius: 4, endRadius: 80
            ))
            .frame(width: 160, height: 160)

        let pip = Circle()
            .fill(Brand.aiBadge.opacity(0.35))
            .frame(width: 6, height: 6)

        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let phase = breathPhase(at: context.date, period: MotionTokens.scanDuration)
            ZStack {
                ring.scaleEffect(0.9 + 0.1 * phase).opacity(0.55 - 0.25 * phase)
                pip
            }
            .position(center)
        }
    }
}

// MARK: - Source Glow

private struct SourceGlow: View {
    let center: CGPoint

    var body: some View {
        let halo = Circle()
            .fill(RadialGradient(
                colors: [Brand.aiGlow.opacity(0.35), Brand.aiGlow.opacity(0.0)],
                center: .center, startRadius: 2, endRadius: 50
            ))
            .frame(width: 100, height: 100)

        let pip = Circle()
            .fill(Brand.aiBadge.opacity(0.5))
            .frame(width: 4, height: 4)

        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let phase = breathPhase(at: context.date, period: MotionTokens.scanDuration)
            ZStack {
                halo.opacity(0.45 - 0.1 * phase)
                pip
            }
            .position(center)
        }
    }
}

// MARK: - Materialization Trace

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
        withAnimation(MotionTokens.morph) { progress = 1 }
    }
}

// MARK: - Helpers

private func breathPhase(at date: Date, period: TimeInterval) -> Double {
    let t = date.timeIntervalSinceReferenceDate
    let angle = (2.0 * .pi * t) / period
    return 0.5 - 0.5 * cos(angle)
}

import SwiftUI

/// Shared motion constants for InkPilot micro-interactions.
/// All springs are intentionally damped (calm, not bouncy) to match the
/// "premium and functional" feel. Pair with `accessibilityReduceMotion`
/// checks where appropriate.
enum Motion {

    // MARK: Spring presets

    /// Default for state changes (toggle, expand, swap). Slight overshoot.
    static let standard = Animation.spring(response: 0.42, dampingFraction: 0.88)

    /// Heavier transitions (cards entering canvas, panel expand).
    static let settle = Animation.spring(response: 0.55, dampingFraction: 0.92)

    /// Soft ease-out for fade-in / fade-out.
    static let fade = Animation.easeOut(duration: 0.28)

    /// Crisp ease for state flips and tool selection.
    static let crisp = Animation.easeInOut(duration: 0.22)

    // MARK: Stagger

    /// Per-card delay when a batch of accepted cards lands on the canvas.
    static let cardStagger: Double = 0.06

    // MARK: Reduce-motion helpers

    /// Returns the given animation if motion is allowed, else a near-instant
    /// opacity-only fallback that still preserves the visual state change.
    static func respecting(_ base: Animation, reduceMotion: Bool) -> Animation {
        reduceMotion ? .linear(duration: 0.01) : base
    }
}

/// Environment-driven wrapper so call sites can pull reduce-motion once.
struct MotionEnvironment {
    let reduceMotion: Bool

    func animation(_ base: Animation) -> Animation {
        Motion.respecting(base, reduceMotion: reduceMotion)
    }
}

// MARK: - View modifiers used by transitions

/// Fade + tiny scale + soft blur pass for ghost-style appearances.
struct GhostAppearModifier: ViewModifier {
    let progress: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(Double(progress))
            .scaleEffect(0.94 + 0.06 * Double(progress))
            .blur(radius: (1 - Double(progress)) * 6)
    }
}

/// Soft settle for items landing on the canvas.
struct CardSettleModifier: ViewModifier {
    let progress: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(Double(progress))
            .scaleEffect(0.92 + 0.08 * Double(progress))
            .offset(y: (1 - Double(progress)) * 8)
    }
}

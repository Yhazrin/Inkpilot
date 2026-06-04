import SwiftUI

/// InkPilot's canonical semantic motion vocabulary.
///
/// Each preset is named for *what it expresses* in the product — not
/// for the curve it uses. A view author asks for `.emerge` or
/// `.materialize` without reasoning about spring parameters.
///
/// All presets respect Reduce Motion via `respecting(_:reduceMotion:)`.
/// Under Reduce Motion, transition presets collapse to a near-instant
/// opacity-only fallback; continuous presets (`scan`, `breathe`) are
/// *not* applied at all (the view should branch with the helper).
///
/// This file does not own animation timers or rendering — it only
/// declares the curves and the small set of view modifiers that screen
/// views compose with.
enum MotionTokens {

    // MARK: - Semantic presets

    /// Continuous, slow breath used for the scan aura while AI is
    /// "thinking". Intended to be applied via `PhaseAnimator` or a
    /// one-shot `withAnimation` — not as a single discrete value.
    static let scan: Animation = .easeInOut(duration: 1.6)

    /// Period of the scan breath in seconds. Exposed separately so
    /// `TimelineView` consumers (e.g. `CanvasMotionLayer`) can drive
    /// the same breath with a `sin` wave without recreating the curve.
    static let scanDuration: TimeInterval = 1.6

    /// A small, soft "born from canvas" feel. Used when the ghost
    /// suggestion card emerges from the suggestion anchor.
    static let emerge: Animation = .spring(response: 0.46, dampingFraction: 0.92)

    /// Travel-from-source. Accepted cards leave the suggestion anchor
    /// and arrive at their world position with a per-card stagger.
    static let materialize: Animation = .spring(response: 0.58, dampingFraction: 0.94)

    /// Snap-into-place feel. Used for things that close a small spatial
    /// gap to a target — the source glow contracting onto the anchor,
    /// or a chip magnetizing to its slot.
    static let magnetize: Animation = .spring(response: 0.34, dampingFraction: 0.88)

    /// Quiet landing. Used for things already on the canvas that adjust
    /// position, size, or content. No overshoot, no bounce.
    static let settle: Animation = .spring(response: 0.48, dampingFraction: 0.96)

    /// Shape-preserving surface morph. AIPilot chip → panel, the
    /// toolbar selected capsule sliding between tools. Continuous, not
    /// bouncy.
    static let morph: Animation = .spring(response: 0.5, dampingFraction: 0.94)

    /// Very slow, very subtle ambient drift for the canvas background.
    /// Reduce Motion disables the animation entirely.
    static let breathe: Animation = .easeInOut(duration: 7.2)

    // MARK: - Stagger & cadence

    /// Per-card delay when a batch of accepted cards materializes.
    static let cardStagger: Double = 0.07

    /// Delay between the ghost card removal and the anchor clear, so
    /// the exit motion can sample the anchor's position.
    static let anchorExitDelay: TimeInterval = 0.6

    /// Delay between the accepted-cards insertion and the anchor clear,
    /// so the materialize travel has its source.
    static let anchorMaterializeDelay: TimeInterval = 0.9

    // MARK: - Reduce Motion helpers

    /// Returns the given animation if motion is allowed, else a
    /// near-instant opacity-only fallback. Use for one-shot transitions.
    static func respecting(_ base: Animation, reduceMotion: Bool) -> Animation {
        reduceMotion ? .linear(duration: 0.01) : base
    }

    /// Returns a `PhaseAnimator`-style animation if motion is allowed,
    /// or `nil` to signal "do nothing". Use for continuous effects
    /// (scan, breathe) — there is no equivalent instantaneous state.
    static func continuous(_ base: Animation, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : base
    }
}

// MARK: - View modifiers used as transition endpoints

/// Soft emerge: at `progress: 0` the view is hidden at the source
/// (offset toward the anchor, slight scale-down, soft blur). At
/// `progress: 1` the view is at its target, full opacity, full scale,
/// no blur.
///
/// Used as the `active` and `identity` endpoints of a
/// `.modifier(active:identity:)` transition so SwiftUI interpolates
/// between the two real view trees.
struct GhostEmergeModifier: ViewModifier {
    let progress: CGFloat
    /// Vector from the final position back to the source. At
    /// `progress: 0` the modifier offsets the view by `travel * 0.4`
    /// (a partial return to the source); at `progress: 1` the offset
    /// is zero.
    let travel: CGSize

    func body(content: Content) -> some View {
        content
            .opacity(Double(progress))
            .scaleEffect(0.86 + 0.14 * Double(progress))
            .blur(radius: (1 - Double(progress)) * 6)
            .offset(
                x: (1 - Double(progress)) * travel.width * 0.4,
                y: (1 - Double(progress)) * travel.height * 0.4
            )
    }
}

/// Materialize: at `progress: 0` the view sits at the source anchor
/// (scale 0.9, opacity 0). At `progress: 1` it rests at its world
/// position. Used as the `active`/`identity` endpoints of a
/// `.modifier(active:identity:)` transition.
struct MaterializeModifier: ViewModifier {
    let progress: CGFloat
    /// Vector from the source to the destination. At `progress: 0` the
    /// view is offset by the full travel; at `progress: 1` the offset
    /// is zero.
    let travel: CGSize

    func body(content: Content) -> some View {
        content
            .opacity(Double(progress))
            .scaleEffect(0.9 + 0.1 * Double(progress))
            .offset(
                x: (1 - Double(progress)) * travel.width,
                y: (1 - Double(progress)) * travel.height
            )
    }
}

/// Magnetize: a softer snap-into-place for things that close a small
/// spatial gap. At `progress: 0` the view is slightly displaced and
/// slightly faded. At `progress: 1` it sits at its final spot.
struct MagnetizeModifier: ViewModifier {
    let progress: CGFloat
    let travel: CGSize

    func body(content: Content) -> some View {
        content
            .opacity(Double(progress))
            .scaleEffect(0.95 + 0.05 * Double(progress))
            .offset(
                x: (1 - Double(progress)) * travel.width,
                y: (1 - Double(progress)) * travel.height
            )
    }
}

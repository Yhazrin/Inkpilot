import SwiftUI

/// InkPilot's semantic motion language.
///
/// Each preset is named for *what it expresses*, not the curve parameters.
/// That way a view author can ask for `.morph` or `.materialize` without
/// reasoning about springs.
///
/// All presets respect Reduce Motion via `respecting(reduceMotion:)`.
/// In Reduce Motion mode we collapse to a near-instant opacity-only
/// transition that still preserves the visual state change.
enum SemanticMotion {

    // MARK: Presets

    /// A small, soft, born-from-canvas feel.
    /// Used when the ghost suggestion card materializes out of ink.
    /// Gentle, slightly overshooting, no bounce.
    static let emerge = Animation.spring(response: 0.46, dampingFraction: 0.88)

    /// Slow, indefinite aura pulse used for the scan layer.
    /// Reduce Motion collapses to a held, motionless state (no pulse).
    static let scan = Animation.easeInOut(duration: 1.6)

    /// Travel-from-source. Accepted cards leave the suggestion anchor
    /// and settle into their world position. Slightly more "weight" than
    /// emerge because the cards are real canvas objects now.
    static let materialize = Animation.spring(response: 0.62, dampingFraction: 0.92)

    /// Quiet landing. Used for things already on the canvas that adjust
    /// position, size, or content. No overshoot, no bounce.
    static let settle = Animation.spring(response: 0.48, dampingFraction: 0.96)

    /// Shape-preserving surface morph. AIPilot chip → panel and toolbar
    /// selected capsule both use this. Continuous, not bouncy.
    static let morph = Animation.spring(response: 0.5, dampingFraction: 0.94)

    /// Very slow, very subtle ambient drift for living-canvas backgrounds.
    /// Reduce Motion holds the layout entirely still.
    static let breathe = Animation.easeInOut(duration: 7.2)

    // MARK: Stagger

    /// Per-card delay when a batch of accepted cards lands on the canvas.
    static let cardStagger: Double = 0.07

    // MARK: Reduce Motion

    /// Returns the given animation if motion is allowed, else a near-instant
    /// opacity-only fallback that still preserves the visual state change.
    static func respecting(_ base: Animation, reduceMotion: Bool) -> Animation {
        reduceMotion ? .linear(duration: 0.01) : base
    }

    /// For indefinite pulses (scan, breathe) Reduce Motion should fully stop
    /// the animation — there is no equivalent instantaneous visual state.
    static func continuous(_ base: Animation, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : base
    }
}

// MARK: - View modifiers used by transitions

/// Fade + tiny scale + soft blur pass for ghost-style appearances.
/// Used when the ghost suggestion card emerges from the suggestion anchor.
struct GhostEmergeModifier: ViewModifier {
    /// 0 = hidden at the source, 1 = fully arrived at its destination offset.
    let progress: CGFloat
    /// Vector from the source anchor to the card's final offset, in points.
    let travel: CGSize

    func body(content: Content) -> some View {
        content
            .opacity(Double(progress))
            .scaleEffect(0.86 + 0.14 * Double(progress))
            .blur(radius: (1 - Double(progress)) * 6)
            .offset(
                x: (1 - Double(progress)) * travel.width * 0.35,
                y: (1 - Double(progress)) * travel.height * 0.35
            )
    }
}

/// Soft settle for items landing on the canvas.
/// Used for accepted cards materializing from the suggestion anchor
/// into their world position.
struct MaterializeModifier: ViewModifier {
    /// 0 = sitting on the source anchor, 1 = resting at world position.
    let progress: CGFloat
    /// Vector from source to destination, in points.
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

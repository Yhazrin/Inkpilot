import SwiftUI

/// InkPilot's canonical semantic motion vocabulary.
/// Each preset is named for what it expresses, not the curve it uses.
enum MotionTokens {

    // MARK: - Semantic presets

    static let scan: Animation = .easeInOut(duration: 1.6)
    static let scanDuration: TimeInterval = 1.6
    static let emerge: Animation = .spring(response: 0.46, dampingFraction: 0.92)
    static let materialize: Animation = .spring(response: 0.58, dampingFraction: 0.94)
    static let settle: Animation = .spring(response: 0.48, dampingFraction: 0.96)
    static let morph: Animation = .spring(response: 0.5, dampingFraction: 0.94)
    /// Palette/panel expand/collapse transition.
    static let palette: Animation = .spring(response: 0.35, dampingFraction: 0.85)
    /// Object add/duplicate transition.
    static let objectAdd: Animation = .spring(response: 0.4, dampingFraction: 0.8)
    /// Alignment panel toggle transition.
    static let alignmentToggle: Animation = .spring(response: 0.3, dampingFraction: 0.85)
    /// AI suggestion accept transition.
    static let suggestionAccept: Animation = .spring(response: 0.55, dampingFraction: 0.9)
    /// Object materialization transition.
    static let objectMaterialize: Animation = .spring(response: 0.5, dampingFraction: 0.8)
    /// Draggable panel drag spring.
    static let panelDrag: Animation = .spring(response: 0.35, dampingFraction: 0.8)
    /// Draggable panel settle spring.
    static let panelSettle: Animation = .spring(response: 0.45, dampingFraction: 0.85)
    /// Quick fade-out (dismiss, cancel).
    static let quickFadeOut: Animation = .easeOut(duration: 0.2)
    /// AI thinking start transition.
    static let thinkingStart: Animation = .easeInOut(duration: 0.25)
    /// AI thinking result transition.
    static let thinkingResult: Animation = .easeInOut(duration: 0.4)
    /// AI thinking end transition.
    static let thinkingEnd: Animation = .easeOut(duration: 0.3)
    /// AI button pulse animation.
    static let aiPulse: Animation = .easeInOut(duration: 1.8).repeatForever(autoreverses: true)
    /// Home screen hero entrance animation.
    static let heroEntrance: Animation = .easeOut(duration: 0.8).delay(0.2)
    /// Empty canvas hint fade animation.
    static let emptyHintFade: Animation = .easeOut(duration: 0.5)

    // MARK: - Transitions

    /// Palette/panel slide down + fade.
    static let slideDownFade: AnyTransition = .move(edge: .top).combined(with: .opacity)
    /// Action bar slide up + fade.
    static let slideUpFade: AnyTransition = .move(edge: .bottom).combined(with: .opacity)
    /// Simple fade transition.
    static let fadeInOut: AnyTransition = .opacity
    /// Scale + fade transition.
    static let scaleFade: AnyTransition = .scale.combined(with: .opacity)

    // MARK: - Stagger & cadence

    static let cardStagger: Double = 0.07
    static let anchorExitDelay: TimeInterval = 0.6
    static let anchorMaterializeDelay: TimeInterval = 0.9

    // MARK: - Reduce Motion helpers

    static func respecting(_ base: Animation, reduceMotion: Bool) -> Animation {
        reduceMotion ? .linear(duration: 0.01) : base
    }
}

// MARK: - Transition modifiers

/// Materialize: at progress 0 the view sits at the source anchor;
/// at progress 1 it rests at its world position.
struct MaterializeModifier: ViewModifier {
    let progress: CGFloat
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

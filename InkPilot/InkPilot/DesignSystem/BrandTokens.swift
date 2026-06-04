import SwiftUI

// MARK: - Brand Tokens

/// Central design tokens for the InkPilot visual system.
/// Pure black & white brand identity (Codex / OpenAI style).
/// Color is reserved for system state only — never decoration.
enum Brand {

    // MARK: Surfaces

    /// Pure white canvas base.
    static let canvasBase = Color.white

    /// Slightly off-white for soft surface variation.
    static let surfaceMuted = Color(white: 0.97)

    /// Near-black inverted surface (for dark panels / contrast moments).
    static let surfaceDark = Color(white: 0.08)

    // MARK: Ink

    /// Primary text and strokes — near-black.
    static let inkPrimary = Color(white: 0.08)

    /// Secondary text and subdued icons.
    static let inkSecondary = Color(white: 0.42)

    /// Tertiary text — used for placeholders and very low emphasis.
    static let inkTertiary = Color(white: 0.62)

    /// Inverse text — for use on dark surfaces.
    static let inkInverse = Color.white

    // MARK: AI Accent (monochrome)

    /// Solid black for AI emphasis (badges, CTAs, selection borders).
    static let aiAccent = Color(white: 0.08)

    /// Soft black for AI radial auras and subtle background tints.
    static let aiHalo = Color(white: 0.08).opacity(0.30)

    /// Black outline at low opacity — used for ghost / pending states.
    static let aiOutline = Color(white: 0.08).opacity(0.18)

    // MARK: Glass

    /// Glass border highlight.
    static let glassBorder = Color.white.opacity(0.45)

    /// Glass shadow color.
    static let glassShadow = Color.black.opacity(0.06)

    // MARK: Typography

    static let largeTitleFont = Font.system(size: 42, weight: .bold, design: .rounded)
    static let titleFont = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 17, weight: .regular, design: .default)
    static let captionFont = Font.system(size: 13, weight: .medium, design: .default)

    // MARK: Spacing

    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 40

    // MARK: Corner Radius

    static let cornerS: CGFloat = 8
    static let cornerM: CGFloat = 16
    static let cornerL: CGFloat = 24
    static let cornerCapsule: CGFloat = 100

    // MARK: Shadow

    static let shadowRadius: CGFloat = 12
    static let shadowY: CGFloat = 4
}

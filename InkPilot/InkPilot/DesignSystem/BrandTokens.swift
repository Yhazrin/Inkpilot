import SwiftUI

// MARK: - Brand Tokens

/// Central design tokens for the InkPilot visual system.
enum Brand {

    // MARK: Colors

    /// Warm off-white base for the canvas background.
    static let canvasBase = Color(red: 0.97, green: 0.96, blue: 0.94)

    /// Soft blue-violet accent block.
    static let accentViolet = Color(red: 0.78, green: 0.76, blue: 0.95).opacity(0.22)

    /// Mint green accent block.
    static let accentMint = Color(red: 0.72, green: 0.92, blue: 0.85).opacity(0.18)

    /// Warm peach accent block.
    static let accentPeach = Color(red: 0.98, green: 0.82, blue: 0.74).opacity(0.18)

    /// Near-black ink with slight warmth.
    static let inkPrimary = Color(red: 0.12, green: 0.11, blue: 0.13)

    /// Secondary ink, lighter.
    static let inkSecondary = Color(red: 0.40, green: 0.38, blue: 0.42)

    /// AI-tinted pale blue for ghost/overlay.
    static let aiGlow = Color(red: 0.60, green: 0.70, blue: 0.95).opacity(0.18)

    /// AI accent — used sparingly (sparkle icon, small dot, gentle tint).
    static let aiBadge = Color(red: 0.55, green: 0.65, blue: 0.95)

    /// Muted AI mark for in-content hints (much quieter than aiBadge).
    static let aiMark = Color(red: 0.55, green: 0.65, blue: 0.95).opacity(0.55)

    // MARK: Glass

    /// Hairline border on top of material — the bright "edge" of glass.
    static let glassHighlight = Color.white.opacity(0.55)

    /// Subtle inner border on top of material — a softer secondary edge.
    static let glassBorder = Color.white.opacity(0.32)

    /// Soft, low-amplitude shadow for floating glass.
    static let glassShadow = Color.black.opacity(0.05)

    /// Even softer shadow for very light surfaces (cards on canvas).
    static let glassShadowSoft = Color.black.opacity(0.035)

    // MARK: Typography

    static let largeTitleFont = Font.system(size: 40, weight: .semibold, design: .rounded)
    static let titleFont = Font.system(size: 19, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 15, weight: .regular, design: .default)
    static let captionFont = Font.system(size: 12, weight: .medium, design: .default)
    static let microFont = Font.system(size: 11, weight: .regular, design: .default)

    // MARK: Spacing

    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 40

    // MARK: Corner Radius

    static let cornerS: CGFloat = 10
    static let cornerM: CGFloat = 18
    static let cornerL: CGFloat = 26
    static let cornerCapsule: CGFloat = 100

    // MARK: Shadow

    static let shadowRadius: CGFloat = 18
    static let shadowY: CGFloat = 6

    /// Hairline stroke width used on glass surfaces.
    static let hairline: CGFloat = 0.5
}

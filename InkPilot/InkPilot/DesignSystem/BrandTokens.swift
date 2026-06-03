import SwiftUI

// MARK: - Brand Tokens

/// Central design tokens for the InkPilot visual system.
enum Brand {

    // MARK: Colors

    /// Warm off-white base for the canvas background.
    static let canvasBase = Color(red: 0.97, green: 0.96, blue: 0.94)

    /// Soft blue-violet accent block.
    static let accentViolet = Color(red: 0.78, green: 0.76, blue: 0.95).opacity(0.35)

    /// Mint green accent block.
    static let accentMint = Color(red: 0.72, green: 0.92, blue: 0.85).opacity(0.30)

    /// Warm peach accent block.
    static let accentPeach = Color(red: 0.98, green: 0.82, blue: 0.74).opacity(0.30)

    /// Near-black ink with slight warmth.
    static let inkPrimary = Color(red: 0.12, green: 0.11, blue: 0.13)

    /// Secondary ink, lighter.
    static let inkSecondary = Color(red: 0.40, green: 0.38, blue: 0.42)

    /// AI-tinted pale blue for ghost/overlay.
    static let aiGlow = Color(red: 0.60, green: 0.70, blue: 0.95).opacity(0.25)

    /// AI badge accent.
    static let aiBadge = Color(red: 0.55, green: 0.65, blue: 0.95)

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

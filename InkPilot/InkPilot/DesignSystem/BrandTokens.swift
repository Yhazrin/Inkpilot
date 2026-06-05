import SwiftUI

// MARK: - Brand Tokens

/// Central design tokens for the InkPilot visual system.
/// All surface/ink/glass colors adapt to light/dark mode.
/// Canvas goes dark in dark mode; components maintain contrast.
enum Brand {

    // MARK: Surfaces (adaptive)

    /// Canvas base — white in light, dark grey in dark.
    static let canvasBase = Color(light: .white, dark: Color(white: 0.11))

    /// Soft surface variation.
    static let surfaceMuted = Color(light: Color(white: 0.97), dark: Color(white: 0.15))

    /// High-contrast surface for panels.
    static let surfaceDark = Color(light: Color(white: 0.08), dark: Color(white: 0.92))

    // MARK: Ink (adaptive)

    /// Primary text — dark on light, light on dark.
    static let inkPrimary = Color(light: Color(white: 0.08), dark: Color(white: 0.92))

    /// Secondary text.
    static let inkSecondary = Color(light: Color(white: 0.42), dark: Color(white: 0.58))

    /// Tertiary / placeholder.
    static let inkTertiary = Color(light: Color(white: 0.62), dark: Color(white: 0.42))

    /// Inverse text.
    static let inkInverse = Color(light: .white, dark: Color(white: 0.08))

    // MARK: AI Accent (adaptive)

    /// AI emphasis — black in light, white in dark.
    static let aiAccent = Color(light: Color(white: 0.08), dark: Color(white: 0.92))

    /// AI halo for auras.
    static let aiHalo = Color(light: Color(white: 0.08), dark: Color(white: 0.92)).opacity(0.30)

    /// AI outline for ghost states.
    static let aiOutline = Color(light: Color(white: 0.08), dark: Color(white: 0.92)).opacity(0.18)

    // MARK: AI Badge (color accent — same in both modes)

    /// AI badge blue accent.
    static let aiBadge = Color(red: 0.35, green: 0.55, blue: 0.90)

    /// AI glow for ghost cards.
    static let aiGlow = Color(red: 0.35, green: 0.55, blue: 0.90).opacity(0.25)

    // MARK: Glass (adaptive)

    /// Glass border — white in light, subtle light in dark.
    static let glassBorder = Color(light: .white.opacity(0.45), dark: .white.opacity(0.12))

    /// Glass shadow.
    static let glassShadow = Color(light: .black.opacity(0.06), dark: .black.opacity(0.20))

    // MARK: Typography

    static let largeTitleFont = Font.system(size: 42, weight: .bold, design: .rounded)
    static let titleFont = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 17, weight: .regular, design: .default)
    static let captionFont = Font.system(size: 13, weight: .medium, design: .default)

    /// Toolbar / palette icon label font.
    static let iconFont = Font.system(size: 16, weight: .medium, design: .default)
    /// Palette item label font (smaller).
    static let paletteFont = Font.system(size: 14, weight: .medium, design: .default)

    // MARK: Touch Targets

    /// Standard 44pt minimum touch target (Apple HIG).
    static let touchTarget: CGFloat = 44
    /// Compact touch target for dense palettes.
    static let touchTargetCompact: CGFloat = 36
    /// Small swatch / chip size.
    static let swatchSize: CGFloat = 24

    // MARK: Canvas Layout

    /// Bottom chrome offset to clear floating toolbar.
    static let chromeBottomOffset: CGFloat = 100
    /// Placeholder icon font size.
    static let placeholderIconSize: CGFloat = 28

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

// MARK: - Adaptive Color Helper

extension Color {
    /// Create a color that adapts between light and dark mode.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}

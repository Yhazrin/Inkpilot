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
    /// Small touch target for action bars.
    static let touchTargetSmall: CGFloat = 40
    /// Small swatch / chip size.
    static let swatchSize: CGFloat = 24

    // MARK: Canvas Layout

    /// Bottom chrome offset to clear floating toolbar.
    static let chromeBottomOffset: CGFloat = 100
    /// Placeholder icon font size.
    static let placeholderIconSize: CGFloat = 28
    /// Max width for prompt capsule.
    static let promptMaxWidth: CGFloat = 480
    /// Progress spinner size.
    static let spinnerSize: CGFloat = 20
    /// Submit button icon size.
    static let submitIconSize: CGFloat = 20
    /// Vertical padding for prompt capsule.
    static let promptPaddingV: CGFloat = 12
    /// Spacing between AI suggestion cards.
    static let aiCardSpacing: CGFloat = 150
    /// Offset when duplicating objects.
    static let duplicateOffset: CGFloat = 28
    /// Stagger between duplicated objects.
    static let duplicateStagger: CGFloat = 8
    /// Default image import size.
    static let imageImportSize = CGSizeCodable(width: 300, height: 200)
    /// Default PDF page import size.
    static let pdfImportSize = CGSizeCodable(width: 400, height: 560)
    /// Vertical spacing between imported PDF pages.
    static let pdfPageSpacing: CGFloat = 620
    /// Maximum canvas zoom scale.
    static let maxZoomScale: CGFloat = 4
    /// Minimum canvas zoom scale.
    static let minZoomScale: CGFloat = 0.25
    /// Highlighter width multiplier (PencilKit marker is wider).
    static let highlighterWidthMultiplier: CGFloat = 3
    /// Max width for hero/home card.
    static let heroCardMaxWidth: CGFloat = 520
    /// Max width for ghost suggestion card.
    static let ghostCardMaxWidth: CGFloat = 360
    /// Dot grid spacing in canvas background.
    static let dotGridSpacing: CGFloat = 40
    /// Dot grid dot size.
    static let dotGridDotSize: CGFloat = 1.5
    /// Empty canvas hint icon size.
    static let emptyHintIconSize: CGFloat = 36
    /// AI badge font size.
    static let aiBadgeFontSize: CGFloat = 10
    /// AI badge horizontal padding.
    static let aiBadgePaddingH: CGFloat = 6
    /// AI badge vertical padding.
    static let aiBadgePaddingV: CGFloat = 2
    /// Compact divider height (palettes, toolbars).
    static let dividerHeight: CGFloat = 20
    /// Tall divider height (action bars, settings).
    static let dividerHeightTall: CGFloat = 24
    /// Opacity slider width.
    static let sliderWidth: CGFloat = 80
    /// Hero card entrance offset.
    static let heroEntranceOffset: CGFloat = 20
    /// Calibration area height.
    static let calibrationAreaHeight: CGFloat = 200
    /// Calibration canvas height.
    static let calibrationCanvasHeight: CGFloat = 280
    /// Pen type selector inner padding.
    static let penTypeSelectorPadding: CGFloat = 2
    /// Bullet dot top padding.
    static let bulletTopPadding: CGFloat = 6
    /// Vignette overlay opacity.
    static let vignetteOpacity: Double = 0.55
    /// Subtle accent opacity (lasso stroke, CTA border, thinking border).
    static let subtleAccentOpacity: Double = 0.4
    /// Marquee/halo highlight opacity.
    static let highlightOpacity: Double = 0.6
    /// Medium emphasis opacity (connector stroke, glow pip).
    static let mediumEmphasisOpacity: Double = 0.5
    /// Scan/glow pip opacity.
    static let glowPipOpacity: Double = 0.35
    /// Sticky note tint opacity.
    static let stickyTintOpacity: Double = 0.2
    /// Very subtle fill opacity (marquee background, dot grid).
    static let subtleFillOpacity: Double = 0.06
    /// Small bullet/dot size (list indicators, pips).
    static let bulletSize: CGFloat = 6
    /// Tiny dot size (motion layer pips).
    static let tinyDotSize: CGFloat = 4
    /// Alignment panel upward offset from action bar.
    static let alignmentPanelOffset: CGFloat = -50
    /// Network request timeout in seconds.
    static let requestTimeout: TimeInterval = 30
    /// Max error snippet length for logging.
    static let errorSnippetLength: Int = 160
    /// Tool button active background opacity.
    static let toolActiveOpacity: Double = 0.08
    /// Disabled button opacity.
    static let disabledOpacity: Double = 0.3
    /// AI accent bullet/indicator opacity.
    static let aiAccentBulletOpacity: Double = 0.3
    /// Connector/resize handle stroke opacity.
    static let handleStrokeOpacity: Double = 0.6
    /// Connector fallback line opacity.
    static let connectorFallbackOpacity: Double = 0.3
    /// Selection/guide border opacity.
    static let selectionBorderOpacity: Double = 0.5
    /// Compact shadow radius (toggle buttons, palette items).
    static let shadowRadiusCompact: CGFloat = 2
    /// Compact shadow Y offset.
    static let shadowYCompact: CGFloat = 1
    /// Medium shadow radius (editable objects).
    static let shadowRadiusMedium: CGFloat = 6
    /// Medium shadow Y offset.
    static let shadowYMedium: CGFloat = 2
    /// Drag shadow radius.
    static let shadowRadiusDrag: CGFloat = 8
    /// Glass border line width.
    static let glassBorderWidth: CGFloat = 0.5
    /// Selection/connector stroke width.
    static let selectionStrokeWidth: CGFloat = 1.5
    /// Thin stroke width (guides, halo outlines).
    static let thinStrokeWidth: CGFloat = 1
    /// Medium stroke width (resize handles, color swatches).
    static let mediumStrokeWidth: CGFloat = 2
    /// Drag-active stroke width.
    static let dragStrokeWidth: CGFloat = 2.5
    /// Small icon size (slider labels, etc).
    static let smallIconSize: CGFloat = 12
    /// Large placeholder icon size (import sheets).
    static let largePlaceholderIconSize: CGFloat = 48
    /// JPEG compression quality for exports.
    static let exportCompressionQuality: CGFloat = 0.9
    /// US Letter page size for PDF export (points).
    static let pdfLetterPageSize = CGSize(width: 612, height: 792)
    /// Default insertion point when no anchor exists (center of typical iPad viewport).
    static let defaultInsertionPoint = CGPointCodable(x: 520, y: 360)

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

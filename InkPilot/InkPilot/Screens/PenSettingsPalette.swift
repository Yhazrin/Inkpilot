import SwiftUI

/// A compact floating palette for pen/drawing tool settings.
/// Shows when pen/pencil/highlighter tool is active.
///
/// **Collapsed (default)**: a single current-state chip — pen type icon,
/// color dot sized by current width, and a chevron. Tapping expands.
///
/// **Expanded**: the full pen type selector, width picker, color swatches,
/// opacity slider, and a collapse button.
struct PenSettingsPalette: View {
    @Bindable var drawingState: DrawingToolState
    @State private var isExpanded: Bool = false

    private let presetColors: [Color] = [
        .black, .blue, .red, .yellow, .green, .purple, .gray
    ]

    private let presetWidths: [CGFloat] = [1.0, 2.0, 4.0, 8.0]

    /// Dot size grows with selected width so the user can read the
    /// current width at a glance even when collapsed.
    private var dotSize: CGFloat {
        10 + min(max(drawingState.width, 1), 8) * 1.75
    }

    private var kindIcon: String {
        switch drawingState.selectedKind {
        case .pen: return "pencil"
        case .pencil: return "pencil.tip"
        case .highlighter: return "highlighter"
        case .eraser: return "eraser"
        }
    }

    var body: some View {
        Group {
            if isExpanded {
                expandedPalette
                    .transition(MotionTokens.slideDownFade)
            } else {
                collapsedIndicator
                    .transition(MotionTokens.slideDownFade)
            }
        }
        .animation(MotionTokens.palette, value: isExpanded)
    }

    // MARK: - Collapsed

    private var collapsedIndicator: some View {
        Button {
            isExpanded = true
        } label: {
            HStack(spacing: Brand.spacingS) {
                Image(systemName: kindIcon)
                    .font(Brand.iconFont)
                    .foregroundStyle(Brand.inkPrimary)
                    .frame(width: Brand.touchTargetCompact, height: Brand.touchTargetCompact)

                Circle()
                    .fill(drawingState.color)
                    .frame(width: dotSize, height: dotSize)
                    .overlay(Circle().strokeBorder(Brand.glassBorder, lineWidth: Brand.glassBorderWidth))

                Image(systemName: "chevron.down")
                    .font(Brand.captionFont)
                    .foregroundStyle(Brand.inkTertiary)
            }
            .padding(.horizontal, Brand.spacingS)
            .padding(.vertical, Brand.bulletTopPadding)
            .background {
                Capsule().fill(.ultraThinMaterial)
            }
            .overlay {
                Capsule().strokeBorder(Brand.glassBorder, lineWidth: Brand.glassBorderWidth)
            }
        }
        .accessibilityLabel(Text(String(localized: "drawing.settings.hint")))
    }

    // MARK: - Expanded

    private var expandedPalette: some View {
        GlassCapsule {
            penTypeSelector

            Divider().frame(height: Brand.dividerHeightTall)

            widthSelector

            Divider().frame(height: Brand.dividerHeightTall)

            colorSwatches

            if drawingState.selectedKind == .highlighter {
                Divider().frame(height: Brand.dividerHeightTall)
                opacitySlider
            }

            Divider().frame(height: Brand.dividerHeightTall)

            Button {
                withAnimation(MotionTokens.palette) { isExpanded = false }
            } label: {
                Image(systemName: "chevron.up")
                    .font(Brand.paletteFont.weight(.semibold))
                    .foregroundStyle(Brand.inkSecondary)
                    .frame(width: Brand.touchTargetCompact, height: Brand.touchTargetCompact)
            }
            .accessibilityLabel(Text(String(localized: "drawing.settings.collapse")))
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(String(localized: "drawing.settings")))
    }

    // MARK: - Pen Type

    private var penTypeSelector: some View {
        HStack(spacing: 2) {
            kindButton(.pen, icon: "pencil", label: String(localized: "tool.pen"))
            kindButton(.pencil, icon: "pencil.tip", label: String(localized: "tool.pencil"))
            kindButton(.highlighter, icon: "highlighter", label: String(localized: "tool.highlighter"))
        }
        .padding(Brand.penTypeSelectorPadding)
        .background(Capsule().fill(Brand.inkPrimary.opacity(Brand.penTypeBgOpacity)))
    }

    private func kindButton(_ kind: DrawingToolKind, icon: String, label: String) -> some View {
        Button {
            drawingState.selectKind(kind)
        } label: {
            Image(systemName: icon)
                .font(Brand.paletteFont)
                .foregroundStyle(drawingState.selectedKind == kind ? Brand.inkPrimary : Brand.inkSecondary)
                .frame(width: Brand.touchTargetCompact, height: Brand.touchTargetCompact)
                .background {
                    if drawingState.selectedKind == kind {
                        Capsule().fill(Brand.canvasBase).shadow(color: Brand.glassShadow, radius: Brand.shadowRadiusCompact, y: Brand.shadowYCompact)
                    }
                }
        }
        .accessibilityLabel(Text(label))
    }

    // MARK: - Width

    private var widthSelector: some View {
        HStack(spacing: 6) {
            ForEach(presetWidths, id: \.self) { w in
                Button {
                    drawingState.selectWidth(w)
                } label: {
                    Circle()
                        .fill(drawingState.width == w ? Brand.inkPrimary : Brand.inkSecondary)
                        .frame(width: w * 3 + 4, height: w * 3 + 4)
                        .overlay {
                            if drawingState.width == w {
                                Circle().strokeBorder(Brand.aiAccent, lineWidth: Brand.selectionStrokeWidth)
                            }
                        }
                }
                .frame(width: Brand.touchTargetCompact, height: Brand.touchTargetCompact)
                .accessibilityLabel(Text(String(format: String(localized: "drawing.width"), Int(w))))
            }
        }
    }

    // MARK: - Colors

    private var colorSwatches: some View {
        HStack(spacing: 6) {
            ForEach(presetColors, id: \.self) { c in
                Button {
                    drawingState.selectColor(c)
                } label: {
                    Circle()
                        .fill(c)
                        .frame(width: Brand.swatchSize, height: Brand.swatchSize)
                        .overlay {
                            if colorsEqual(drawingState.color, c) {
                                Circle().strokeBorder(Brand.canvasBase, lineWidth: Brand.mediumStrokeWidth)
                                    .shadow(color: Brand.glassShadow, radius: Brand.shadowRadiusCompact, y: Brand.shadowYCompact)
                            }
                        }
                }
                .frame(width: Brand.touchTargetCompact, height: Brand.touchTargetCompact)
                .accessibilityLabel(Text(colorName(c)))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(String(localized: "drawing.color")))
    }

    // MARK: - Opacity

    private var opacitySlider: some View {
        HStack(spacing: Brand.spacingS) {
            Image(systemName: "circle.lefthalf.filled")
                .font(.system(size: Brand.smallIconSize))
                .foregroundStyle(Brand.inkSecondary)
            Slider(value: $drawingState.opacity, in: Brand.minHighlighterOpacity...1.0)
                .frame(width: Brand.sliderWidth)
                .accessibilityLabel(Text(String(localized: "drawing.opacity")))
            Image(systemName: "circle.fill")
                .font(.system(size: Brand.smallIconSize))
                .foregroundStyle(Brand.inkSecondary)
        }
    }

    // MARK: - Helpers

    private func colorsEqual(_ a: Color, _ b: Color) -> Bool {
        UIColor(a).cgColor == UIColor(b).cgColor
    }

    private func colorName(_ c: Color) -> String {
        let ui = UIColor(c)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: nil)
        if r < 0.1 && g < 0.1 && b < 0.1 { return String(localized: "drawing.black") }
        if r < 0.1 && g < 0.1 && b > 0.8 { return String(localized: "drawing.blue") }
        if r > 0.8 && g < 0.1 && b < 0.1 { return String(localized: "drawing.red") }
        if r > 0.8 && g > 0.8 && b < 0.1 { return String(localized: "drawing.yellow") }
        if r < 0.1 && g > 0.6 && b < 0.3 { return String(localized: "drawing.green") }
        if r > 0.5 && g < 0.1 && b > 0.5 { return String(localized: "drawing.purple") }
        return String(localized: "drawing.gray")
    }
}

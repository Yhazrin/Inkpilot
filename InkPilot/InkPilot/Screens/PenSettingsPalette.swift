import SwiftUI

/// A compact floating palette for pen/drawing tool settings.
/// Shows when pen/pencil/highlighter tool is active.
struct PenSettingsPalette: View {
    @Bindable var drawingState: DrawingToolState

    private let presetColors: [Color] = [
        .black, .blue, .red, .yellow, .green, .purple, .gray
    ]

    private let presetWidths: [CGFloat] = [1.0, 2.0, 4.0, 8.0]

    var body: some View {
        GlassCapsule {
            // Pen type selector
            penTypeSelector

            Divider().frame(height: Brand.dividerHeightTall)

            // Width selector
            widthSelector

            Divider().frame(height: Brand.dividerHeightTall)

            // Color swatches
            colorSwatches

            // Opacity for highlighter
            if drawingState.selectedKind == .highlighter {
                Divider().frame(height: Brand.dividerHeightTall)
                opacitySlider
            }
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
        .padding(2)
        .background(Capsule().fill(Brand.inkPrimary.opacity(0.05)))
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
                        Capsule().fill(Brand.canvasBase).shadow(color: Brand.glassShadow, radius: 2, y: 1)
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
                                Circle().strokeBorder(Brand.aiBadge, lineWidth: 1.5)
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
                                Circle().strokeBorder(Brand.canvasBase, lineWidth: 2)
                                    .shadow(color: Brand.glassShadow, radius: 2, y: 1)
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
            Slider(value: $drawingState.opacity, in: 0.2...1.0)
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

import SwiftUI

/// Canvas background that adapts to light/dark mode.
/// Light: warm off-white with soft vignette.
/// Dark: deep grey canvas with subtle warm undertone.
struct ColorBlockBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base canvas color (adaptive)
                Brand.canvasBase
                    .ignoresSafeArea()

                // Subtle vignette for depth
                vignette(in: geo.size)

                // Faint dot grid for spatial depth
                dotGrid(in: geo.size)
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func vignette(in size: CGSize) -> some View {
        if colorScheme == .dark {
            RadialGradient(
                colors: [
                    Color(white: 0.13),
                    Color(white: 0.10),
                    Color(white: 0.08),
                ],
                center: UnitPoint(x: 0.25, y: 0.2),
                startRadius: 0,
                endRadius: max(size.width, size.height) * 0.9
            )
            .ignoresSafeArea()
            .opacity(Brand.vignetteOpacity)
        } else {
            RadialGradient(
                colors: [
                    Color.white,
                    Color(white: 0.96),
                    Color(white: 0.93),
                ],
                center: UnitPoint(x: 0.25, y: 0.2),
                startRadius: 0,
                endRadius: max(size.width, size.height) * 0.9
            )
            .ignoresSafeArea()
            .opacity(Brand.vignetteOpacity)
        }
    }

    private func dotGrid(in size: CGSize) -> some View {
        let spacing = Brand.dotGridSpacing
        let dotSize = Brand.dotGridDotSize
        let columns = Int(size.width / spacing) + 1
        let rows = Int(size.height / spacing) + 1
        let dotColor = colorScheme == .dark
            ? Color.white.opacity(0.06)
            : Color(white: 0.42).opacity(0.08)

        return Canvas { context, _ in
            for row in 0...rows {
                for col in 0...columns {
                    let x = CGFloat(col) * spacing
                    let y = CGFloat(row) * spacing
                    let rect = CGRect(
                        x: x - dotSize / 2,
                        y: y - dotSize / 2,
                        width: dotSize,
                        height: dotSize
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(dotColor))
                }
            }
        }
    }
}

#Preview("Light") {
    ColorBlockBackground()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ColorBlockBackground()
        .preferredColorScheme(.dark)
}

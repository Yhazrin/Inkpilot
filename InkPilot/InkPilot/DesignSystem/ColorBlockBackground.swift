import SwiftUI

/// A calm, spatial background for the canvas.
/// Pure black & white: white base + a single soft grey radial for paper-like
/// depth, plus a faint dot grid.
struct ColorBlockBackground: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Pure white base
                Brand.canvasBase
                    .ignoresSafeArea()

                // Subtle paper-like vignette (greyscale only)
                RadialGradient(
                    colors: [Color.white, Color(white: 0.96), Color(white: 0.93)],
                    center: UnitPoint(x: 0.25, y: 0.2),
                    startRadius: 0,
                    endRadius: max(geo.size.width, geo.size.height) * 0.9
                )
                .ignoresSafeArea()
                .opacity(0.55)

                // Faint dot grid for spatial depth
                dotGrid(in: geo.size)
            }
        }
        .ignoresSafeArea()
    }

    /// Very subtle dot grid pattern.
    private func dotGrid(in size: CGSize) -> some View {
        let spacing: CGFloat = 40
        let dotSize: CGFloat = 1.5
        let columns = Int(size.width / spacing) + 1
        let rows = Int(size.height / spacing) + 1

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
                    context.fill(Path(ellipseIn: rect), with: .color(Brand.inkSecondary.opacity(0.08)))
                }
            }
        }
    }
}

#Preview {
    ColorBlockBackground()
}

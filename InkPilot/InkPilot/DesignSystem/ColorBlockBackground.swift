import SwiftUI

/// A flat, spatial background for the canvas.
///
/// Composition (bottom → top):
///   1. Warm off-white canvas base.
///   2. A very subtle dot grid (40pt spacing) for spatial reference —
///      the kind of grid a paper notebook has, not a high-contrast
///      tech grid.
///   3. Three barely-there color fields (violet, mint, peach) placed
///      at the corners, very low opacity, heavily blurred. They give
///      the canvas a hint of spatial depth without performing.
///
/// **No** animated blobs. **No** breath. The background supports the
/// content — it does not perform for the user.
struct ColorBlockBackground: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Warm off-white base
                Brand.canvasBase
                    .ignoresSafeArea()

                // 2. Barely-there color fields. Static composition —
                // they live in the corners and never move.
                Group {
                    Circle()
                        .fill(Brand.accentViolet)
                        .frame(width: geo.size.width * 0.6, height: geo.size.width * 0.6)
                        .blur(radius: 120)
                        .offset(
                            x: -geo.size.width * 0.25,
                            y: -geo.size.height * 0.2
                        )
                        .opacity(0.55)

                    Circle()
                        .fill(Brand.accentMint)
                        .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.5)
                        .blur(radius: 110)
                        .offset(
                            x: geo.size.width * 0.3,
                            y: geo.size.height * 0.15
                        )
                        .opacity(0.45)

                    Circle()
                        .fill(Brand.accentPeach)
                        .frame(width: geo.size.width * 0.45, height: geo.size.width * 0.45)
                        .blur(radius: 110)
                        .offset(
                            x: -geo.size.width * 0.15,
                            y: geo.size.height * 0.3
                        )
                        .opacity(0.4)
                }

                // 3. Subtle dot grid for spatial reference
                dotGrid(in: geo.size)
            }
        }
        .ignoresSafeArea()
    }

    /// Very subtle dot grid pattern. 40pt spacing, 1.5pt dots, very
    /// low contrast — the kind of grid a notebook has.
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
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(Brand.inkSecondary.opacity(0.07))
                    )
                }
            }
        }
    }
}

#Preview {
    ColorBlockBackground()
}

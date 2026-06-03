import SwiftUI

/// A calm, spatial background with large soft color blocks
/// that gives the canvas an infinite, premium feel.
struct ColorBlockBackground: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base warm off-white
                Brand.canvasBase
                    .ignoresSafeArea()

                // Soft color blocks — oversized, blurred, low-contrast
                Circle()
                    .fill(Brand.accentViolet)
                    .frame(width: geo.size.width * 0.6, height: geo.size.width * 0.6)
                    .blur(radius: 120)
                    .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.15)

                Circle()
                    .fill(Brand.accentMint)
                    .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.5)
                    .blur(radius: 100)
                    .offset(x: geo.size.width * 0.25, y: geo.size.height * 0.1)

                Circle()
                    .fill(Brand.accentPeach)
                    .frame(width: geo.size.width * 0.45, height: geo.size.width * 0.45)
                    .blur(radius: 110)
                    .offset(x: -geo.size.width * 0.1, y: geo.size.height * 0.25)

                // Subtle dot grid for spatial depth
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

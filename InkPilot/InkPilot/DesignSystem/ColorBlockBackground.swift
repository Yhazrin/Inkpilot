import SwiftUI

/// A calm, spatial background with large soft color blocks
/// that gives the canvas an infinite, premium feel. Saturated
/// rainbow gradients are intentionally avoided — the blocks use
/// very low-opacity tints so the canvas reads as warm off-white
/// with hints of color, not as a colored page.
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
                    .frame(width: geo.size.width * 0.9, height: geo.size.width * 0.9)
                    .blur(radius: 160)
                    .offset(x: -geo.size.width * 0.25, y: -geo.size.height * 0.25)

                Circle()
                    .fill(Brand.accentMint)
                    .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                    .blur(radius: 150)
                    .offset(x: geo.size.width * 0.30, y: geo.size.height * 0.15)

                Circle()
                    .fill(Brand.accentPeach)
                    .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                    .blur(radius: 140)
                    .offset(x: -geo.size.width * 0.05, y: geo.size.height * 0.30)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ColorBlockBackground()
}

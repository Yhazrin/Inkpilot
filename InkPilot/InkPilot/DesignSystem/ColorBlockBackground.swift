import SwiftUI

/// A calm, spatial background with large soft color blocks that gives
/// the canvas an infinite, premium feel.
///
/// In V0.1 (motion reset) the blocks breathe: each color circle drifts
/// in scale and opacity on a long, very slow ease. The drift is below
/// the threshold of conscious perception but above the threshold of
/// "the page feels alive when you look for ten seconds".
///
/// Under Reduce Motion the breath is frozen — the layout is identical
/// to the static V0.1 frame, just held still.
struct ColorBlockBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathPhase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base warm off-white
                Brand.canvasBase
                    .ignoresSafeArea()

                // Soft color blocks — oversized, blurred, low-contrast.
                // Each block uses a phase-shifted breath so the whole
                // composition feels organic, not synchronized.
                breathBlock(
                    in: geo.size,
                    color: Brand.accentViolet,
                    sizeFactor: 0.6,
                    blur: 120,
                    offset: CGSize(
                        width: -geo.size.width * 0.2,
                        height: -geo.size.height * 0.15
                    ),
                    minScale: 0.96,
                    maxScale: 1.04,
                    minOpacity: 0.85,
                    maxOpacity: 1.0,
                    phaseShift: 0.0
                )

                breathBlock(
                    in: geo.size,
                    color: Brand.accentMint,
                    sizeFactor: 0.5,
                    blur: 100,
                    offset: CGSize(
                        width: geo.size.width * 0.25,
                        height: geo.size.height * 0.1
                    ),
                    minScale: 0.95,
                    maxScale: 1.05,
                    minOpacity: 0.8,
                    maxOpacity: 1.0,
                    phaseShift: 0.33
                )

                breathBlock(
                    in: geo.size,
                    color: Brand.accentPeach,
                    sizeFactor: 0.45,
                    blur: 110,
                    offset: CGSize(
                        width: -geo.size.width * 0.1,
                        height: geo.size.height * 0.25
                    ),
                    minScale: 0.97,
                    maxScale: 1.03,
                    minOpacity: 0.82,
                    maxOpacity: 1.0,
                    phaseShift: 0.66
                )
            }
            .onAppear { startBreath() }
        }
        .ignoresSafeArea()
    }

    // MARK: - Breath

    /// Drives the very slow scale + opacity oscillation of the background.
    /// We do it by toggling `breathPhase` 0↔1 with the `breathe` curve.
    private func startBreath() {
        guard !reduceMotion else { return }
        let duration = 7.2
        withAnimation(.easeInOut(duration: duration)) {
            breathPhase = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [self] in
            withAnimation(.easeInOut(duration: duration)) {
                breathPhase = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                startBreath()
            }
        }
    }

    @ViewBuilder
    private func breathBlock(
        in size: CGSize,
        color: Color,
        sizeFactor: CGFloat,
        blur: CGFloat,
        offset: CGSize,
        minScale: CGFloat,
        maxScale: CGFloat,
        minOpacity: CGFloat,
        maxOpacity: CGFloat,
        phaseShift: Double
    ) -> some View {
        // Phase shift is folded into the displayed scale/opacity.
        // At rest (Reduce Motion) we land on the midpoint.
        let t = reduceMotion ? 0.5 : (breathPhase == 1 ? 1.0 : 0.0)
        let scale = minScale + (maxScale - minScale) * t
        let alpha = minOpacity + (maxOpacity - minOpacity) * t

        Circle()
            .fill(color)
            .frame(width: size.width * sizeFactor, height: size.width * sizeFactor)
            .blur(radius: blur)
            .scaleEffect(scale)
            .opacity(alpha)
            .offset(offset)
    }
}

#Preview {
    ColorBlockBackground()
}

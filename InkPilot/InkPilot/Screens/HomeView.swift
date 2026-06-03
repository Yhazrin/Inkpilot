import SwiftUI

/// The InkPilot home screen.
/// Shows the brand hero card and a "New AI Canvas" CTA.
struct HomeView: View {
    @State private var showCanvas = false

    var body: some View {
        ZStack {
            ColorBlockBackground()

            VStack(spacing: Brand.spacingXL) {
                Spacer()

                heroCard

                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showCanvas) {
            CanvasView()
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        GlassCard(cornerRadius: Brand.cornerL) {
            VStack(spacing: Brand.spacingL) {
                Text(String(localized: "home.title"))
                    .font(Brand.largeTitleFont)
                    .foregroundStyle(Brand.inkPrimary)

                VStack(spacing: Brand.spacingS) {
                    Text(String(localized: "home.subtitle1"))
                        .font(Brand.titleFont)
                        .foregroundStyle(Brand.inkSecondary)

                    Text(String(localized: "home.subtitle2"))
                        .font(Brand.titleFont)
                        .foregroundStyle(Brand.inkSecondary)
                }

                Button(action: { showCanvas = true }) {
                    Label(
                        String(localized: "home.newCanvas"),
                        systemImage: "plus.circle.fill"
                    )
                    .font(Brand.titleFont)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Brand.spacingL)
                    .padding(.vertical, Brand.spacingM)
                    .background {
                        Capsule()
                            .fill(Brand.aiBadge)
                    }
                }
                .accessibilityLabel(Text(String(localized: "home.newCanvas.accessibility")))
                .accessibilityHint(Text(String(localized: "home.newCanvas.hint")))
            }
            .padding(Brand.spacingXL)
        }
        .frame(maxWidth: 520)
    }
}

#Preview {
    HomeView()
}

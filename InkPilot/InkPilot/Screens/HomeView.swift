import SwiftUI

/// The InkPilot home screen.
/// Shows the brand hero card and a "New AI Canvas" CTA.
struct HomeView: View {
    @State private var showCanvas = false
    @State private var hasAppeared = false

    var body: some View {
        ZStack {
            ColorBlockBackground()

            VStack(spacing: Brand.spacingXL) {
                Spacer()

                heroCard
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 20)

                // Version info
                Text(versionString)
                    .font(Brand.captionFont)
                    .foregroundStyle(Brand.inkTertiary)
                    .opacity(hasAppeared ? 1 : 0)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                hasAppeared = true
            }
        }
        .fullScreenCover(isPresented: $showCanvas) {
            CanvasView()
        }
        #if DEBUG
        .onAppear {
            // Debug-only launch flag: `-autoCanvas 1` skips Home and
            // opens the canvas directly for screenshot capture.
            let args = ProcessInfo.processInfo.arguments
            if args.contains("-autoCanvas") || args.contains("-autoCanvas 1") {
                showCanvas = true
            }
        }
        #endif
    }

    // MARK: - Version

    private var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return String(localized: "home.version \(version) \(build)")
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
                    .foregroundStyle(Brand.inkInverse)
                    .padding(.horizontal, Brand.spacingL)
                    .padding(.vertical, Brand.spacingM)
                    .background {
                        Capsule()
                            .fill(Brand.aiAccent)
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

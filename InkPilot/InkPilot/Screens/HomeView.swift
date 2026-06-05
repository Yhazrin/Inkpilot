import SwiftUI

/// The InkPilot home screen.
/// Shows the brand hero card and a "New AI Canvas" CTA.
struct HomeView: View {
    @State private var showCanvas = false
    @State private var showCalibration = false
    @State private var hasAppeared = false

    var body: some View {
        ZStack {
            ColorBlockBackground()

            if !showCanvas {
                VStack(spacing: Brand.spacingXL) {
                    Spacer()

                    heroCard
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : Brand.heroEntranceOffset)

                    // Version info
                    Text(versionString)
                        .font(Brand.captionFont)
                        .foregroundStyle(Brand.inkTertiary)
                        .opacity(hasAppeared ? 1 : 0)

                    Spacer()
                }
            }
        }
        .accessibilityHidden(showCanvas)
        .sheet(isPresented: $showCalibration) {
            HandwritingCalibrationView()
        }
        .onAppear {
            withAnimation(MotionTokens.heroEntrance) {
                hasAppeared = true
            }
        }
        .fullScreenCover(isPresented: $showCanvas) {
            CanvasView()
        }
        #if DEBUG
        .onAppear {
            if DebugLaunchOptions.nukePersist, let docs = try? FileManager.default.url(
                for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false
            ) {
                let f = docs.appendingPathComponent("inkpilot_canvas.json")
                try? FileManager.default.removeItem(at: f)
            }
            if DebugLaunchOptions.autoCanvas {
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

                Button(action: { showCalibration = true }) {
                    Label(
                        String(localized: "home.calibrateHandwriting"),
                        systemImage: "pencil.tip.crop.circle"
                    )
                    .font(Brand.bodyFont)
                    .foregroundStyle(Brand.inkPrimary)
                    .padding(.horizontal, Brand.spacingL)
                    .padding(.vertical, Brand.spacingS)
                    .background {
                        Capsule()
                            .strokeBorder(Brand.inkPrimary.opacity(0.4), lineWidth: Brand.thinStrokeWidth)
                    }
                }
                .accessibilityLabel(Text(String(localized: "home.calibrateHandwriting.accessibility")))
            }
            .padding(Brand.spacingXL)
        }
        .frame(maxWidth: Brand.heroCardMaxWidth)
    }
}

#Preview {
    HomeView()
}

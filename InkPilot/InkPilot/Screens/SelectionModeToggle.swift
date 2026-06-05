import SwiftUI

/// A compact toggle between marquee and lasso selection modes.
struct SelectionModeToggle: View {
    @Binding var useLasso: Bool

    var body: some View {
        GlassCapsule {
            Button {
                useLasso = false
            } label: {
                Image(systemName: "rectangle.dashed")
                    .font(Brand.paletteFont)
                    .foregroundStyle(!useLasso ? Brand.inkPrimary : Brand.inkSecondary)
                    .frame(width: Brand.touchTargetCompact, height: Brand.touchTargetCompact)
                    .background {
                        if !useLasso {
                            Capsule().fill(Brand.canvasBase).shadow(color: Brand.glassShadow, radius: Brand.shadowRadiusCompact, y: Brand.shadowYCompact)
                        }
                    }
            }
            .accessibilityLabel(Text(String(localized: "selection.marquee")))

            Button {
                useLasso = true
            } label: {
                Image(systemName: "pencil.line")
                    .font(Brand.paletteFont)
                    .foregroundStyle(useLasso ? Brand.inkPrimary : Brand.inkSecondary)
                    .frame(width: Brand.touchTargetCompact, height: Brand.touchTargetCompact)
                    .background {
                        if useLasso {
                            Capsule().fill(Brand.canvasBase).shadow(color: Brand.glassShadow, radius: Brand.shadowRadiusCompact, y: Brand.shadowYCompact)
                        }
                    }
            }
            .accessibilityLabel(Text(String(localized: "selection.lasso")))
        }
    }
}

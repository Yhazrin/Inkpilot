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
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(!useLasso ? Brand.inkPrimary : Brand.inkSecondary)
                    .frame(width: 36, height: 36)
                    .background {
                        if !useLasso {
                            Capsule().fill(Brand.canvasBase).shadow(color: Brand.glassShadow, radius: 2, y: 1)
                        }
                    }
            }
            .accessibilityLabel(Text(String(localized: "selection.marquee")))

            Button {
                useLasso = true
            } label: {
                Image(systemName: "pencil.line")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(useLasso ? Brand.inkPrimary : Brand.inkSecondary)
                    .frame(width: 36, height: 36)
                    .background {
                        if useLasso {
                            Capsule().fill(Brand.canvasBase).shadow(color: Brand.glassShadow, radius: 2, y: 1)
                        }
                    }
            }
            .accessibilityLabel(Text(String(localized: "selection.lasso")))
        }
    }
}

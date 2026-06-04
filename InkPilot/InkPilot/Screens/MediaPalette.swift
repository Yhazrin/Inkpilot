import SwiftUI

/// A floating palette for inserting media placeholders.
struct MediaPalette: View {
    var onSelect: (CanvasObjectType) -> Void
    var onClose: () -> Void

    var body: some View {
        GlassCapsule {
            Button {
                onSelect(.image)
            } label: {
                Label(String(localized: "palette.media.image"), systemImage: "photo")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Brand.inkPrimary)
                    .frame(height: 44)
            }
            .accessibilityLabel(Text(String(localized: "palette.media.image.accessibility")))

            Button {
                onSelect(.file)
            } label: {
                Label(String(localized: "palette.media.file"), systemImage: "doc")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Brand.inkPrimary)
                    .frame(height: 44)
            }
            .accessibilityLabel(Text(String(localized: "palette.media.file.accessibility")))

            Divider().frame(height: 20)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Brand.inkSecondary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text(String(localized: "palette.close")))
        }
    }
}

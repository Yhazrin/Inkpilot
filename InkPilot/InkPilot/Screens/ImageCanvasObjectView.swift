import SwiftUI

/// Renders an actual imported image as a canvas object.
/// Loads the image from disk via MediaAssetStore.
struct ImageCanvasObjectView: View {
    let assetID: String?
    @State private var uiImage: UIImage?

    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: Brand.cornerS, style: .continuous))
            } else {
                placeholderView
            }
        }
        .onAppear { loadImage() }
        .accessibilityLabel(Text(String(localized: "object.image.accessibility")))
    }

    private var placeholderView: some View {
        GlassCard(cornerRadius: Brand.cornerS) {
            VStack(spacing: Brand.spacingS) {
                Image(systemName: "photo")
                    .font(.system(size: Brand.placeholderIconSize))
                    .foregroundStyle(Brand.inkSecondary)
                Text(String(localized: "object.image.loading"))
                    .font(Brand.captionFont)
                    .foregroundStyle(Brand.inkSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func loadImage() {
        guard let assetID, let uuid = UUID(uuidString: assetID) else { return }
        // Load from documents directory
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = dir.appendingPathComponent("canvas_images/\(uuid.uuidString).jpg")
        if let data = try? Data(contentsOf: fileURL) {
            uiImage = UIImage(data: data)
        }
    }
}

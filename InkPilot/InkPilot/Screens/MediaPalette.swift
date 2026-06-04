import SwiftUI
import PhotosUI

/// A floating palette for inserting media — now with real image import.
struct MediaPalette: View {
    var onInsertPlaceholder: (CanvasObjectType) -> Void
    var onImportImage: (Data, String) -> Void
    var onClose: () -> Void

    @State private var showPhotosPicker = false

    var body: some View {
        GlassCapsule {
            // Real image import
            Button {
                showPhotosPicker = true
            } label: {
                Label(String(localized: "media.import.image"), systemImage: "photo.badge.plus")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Brand.aiAccent)
                    .frame(height: 44)
            }
            .accessibilityLabel(Text(String(localized: "media.import.image.accessibility")))

            // Placeholder image
            Button {
                onInsertPlaceholder(.image)
            } label: {
                Label(String(localized: "palette.media.image"), systemImage: "photo")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Brand.inkPrimary)
                    .frame(height: 44)
            }
            .accessibilityLabel(Text(String(localized: "palette.media.image.accessibility")))

            // File placeholder
            Button {
                onInsertPlaceholder(.file)
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
        .photosPicker(
            isPresented: $showPhotosPicker,
            selection: .constant(nil),
            matching: .images
        )
        .onChange(of: showPhotosPicker) { _, isShowing in
            // PhotosPicker handled via sheet
        }
        .sheet(isPresented: $showPhotosPicker) {
            PhotoImportSheet { data, name in
                onImportImage(data, name)
            }
        }
    }
}

/// A simple photo import sheet using PhotosPicker.
private struct PhotoImportSheet: View {
    var onImport: (Data, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                VStack(spacing: Brand.spacingL) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundStyle(Brand.inkSecondary)
                    Text(String(localized: "media.import.selectPhoto"))
                        .font(Brand.titleFont)
                        .foregroundStyle(Brand.inkPrimary)
                    Text(String(localized: "media.import.hint"))
                        .font(Brand.bodyFont)
                        .foregroundStyle(Brand.inkSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Brand.canvasBase)
            }
            .navigationTitle(String(localized: "media.import.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "media.import.cancel")) { dismiss() }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        let name = newItem.itemIdentifier ?? "imported.jpg"
                        onImport(data, name)
                    }
                    dismiss()
                }
            }
        }
    }
}

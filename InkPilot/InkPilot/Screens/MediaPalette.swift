import SwiftUI
import PhotosUI

/// A floating palette for inserting media — images, PDFs, and placeholders.
struct MediaPalette: View {
    var onInsertPlaceholder: (CanvasObjectType) -> Void
    var onImportImage: (Data, String) -> Void
    var onImportPDF: (URL) -> Void
    var onClose: () -> Void

    @State private var showPhotosPicker = false
    @State private var showPDFPicker = false

    var body: some View {
        GlassCapsule {
            // Real image import
            Button {
                showPhotosPicker = true
            } label: {
                Label(String(localized: "media.import.image"), systemImage: "photo.badge.plus")
                    .font(Brand.paletteFont)
                    .foregroundStyle(Brand.aiBadge)
                    .frame(height: 44)
            }
            .accessibilityLabel(Text(String(localized: "media.import.image.accessibility")))

            // PDF import
            Button {
                showPDFPicker = true
            } label: {
                Label(String(localized: "media.import.pdf"), systemImage: "doc.richtext")
                    .font(Brand.paletteFont)
                    .foregroundStyle(Brand.inkPrimary)
                    .frame(height: 44)
            }
            .accessibilityLabel(Text(String(localized: "media.import.pdf.accessibility")))

            Divider().frame(height: 20)

            // Placeholder image
            Button {
                onInsertPlaceholder(.image)
            } label: {
                Label(String(localized: "palette.media.image"), systemImage: "photo")
                    .font(Brand.paletteFont)
                    .foregroundStyle(Brand.inkSecondary)
                    .frame(height: 44)
            }
            .accessibilityLabel(Text(String(localized: "palette.media.image.accessibility")))

            // File placeholder
            Button {
                onInsertPlaceholder(.file)
            } label: {
                Label(String(localized: "palette.media.file"), systemImage: "doc")
                    .font(Brand.paletteFont)
                    .foregroundStyle(Brand.inkSecondary)
                    .frame(height: 44)
            }
            .accessibilityLabel(Text(String(localized: "palette.media.file.accessibility")))

            Divider().frame(height: 20)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(Brand.paletteFont.weight(.semibold))
                    .foregroundStyle(Brand.inkSecondary)
                    .frame(width: Brand.touchTarget, height: Brand.touchTarget)
            }
            .accessibilityLabel(Text(String(localized: "palette.close")))
        }
        .sheet(isPresented: $showPhotosPicker) {
            PhotoImportSheet { data, name in
                onImportImage(data, name)
            }
        }
        .sheet(isPresented: $showPDFPicker) {
            PDFImportPicker(isPresented: $showPDFPicker) { url in
                onImportPDF(url)
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
                        .font(.system(size: Brand.largePlaceholderIconSize))
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

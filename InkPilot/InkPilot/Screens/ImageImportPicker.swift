import SwiftUI
import PhotosUI
import _PhotosUI_SwiftUI

/// A PhotosPicker wrapper for importing images into the canvas.
struct ImageImportPicker: View {
    @Binding var isPresented: Bool
    var onImport: (Data, String) -> Void

    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Label(String(localized: "media.import.image"), systemImage: "photo.badge.plus")
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = await ImageImportService.loadData(from: newItem) {
                    let fileName = newItem.itemIdentifier ?? "imported.jpg"
                    onImport(data, fileName)
                }
                isPresented = false
            }
        }
    }
}

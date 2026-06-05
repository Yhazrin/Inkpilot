import SwiftUI
import PDFKit

/// Renders a PDF page as a canvas object.
struct PDFCanvasObjectView: View {
    let pdfURL: URL?
    let pageIndex: Int
    @State private var pageImage: UIImage?

    var body: some View {
        Group {
            if let pageImage {
                Image(uiImage: pageImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: Brand.cornerS, style: .continuous))
                    .shadow(color: Brand.glassShadow, radius: 4, y: 2)
            } else {
                placeholderView
            }
        }
        .onAppear { loadPage() }
        .accessibilityLabel(Text(String(localized: "object.pdf.accessibility")))
    }

    private var placeholderView: some View {
        GlassCard(cornerRadius: Brand.cornerS) {
            VStack(spacing: Brand.spacingS) {
                Image(systemName: "doc.richtext")
                    .font(.system(size: Brand.placeholderIconSize))
                    .foregroundStyle(Brand.inkSecondary)
                Text(String(localized: "object.pdf.loading"))
                    .font(Brand.captionFont)
                    .foregroundStyle(Brand.inkSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func loadPage() {
        guard let pdfURL,
              let document = PDFDocument(url: pdfURL),
              let page = document.page(at: pageIndex) else { return }
        let size = CGSize(width: 400, height: 560)
        pageImage = PDFService.renderPage(page, at: size)
    }
}

/// A view for the PDF document picker.
struct PDFImportPicker: View {
    @Binding var isPresented: Bool
    var onImport: (URL) -> Void

    var body: some View {
        DocumentPicker(onPick: { url in
            onImport(url)
            isPresented = false
        })
    }
}

/// UIKit document picker wrapper.
private struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void

        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}

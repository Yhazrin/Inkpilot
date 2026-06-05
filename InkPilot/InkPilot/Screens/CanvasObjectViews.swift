import SwiftUI
import PencilKit

/// Routes a CanvasObject to the correct specialized view based on content.
struct CanvasObjectView: View {
    let object: CanvasObject
    let isSelected: Bool
    let isEditing: Bool
    var isDragging: Bool = false
    var isConnectorStart: Bool = false
    var allObjects: [CanvasObject] = []
    var onTextChange: ((String) -> Void)?
    var onEndEditing: (() -> Void)?
    var onResize: ((CGSize) -> Void)?
    var onResizeStart: (() -> Void)?

    var body: some View {
        Group {
            switch object.content {
            case .aiCard(let title, let body):
                AICardObjectView(title: title, bodyText: body)
            case .text(let text):
                EditableTextObjectView(
                    text: text, isEditing: isEditing,
                    onChange: onTextChange, onEndEditing: onEndEditing
                )
            case .stickyNote(let noteText):
                EditableStickyNoteView(
                    noteText: noteText, tint: object.style.tint,
                    isEditing: isEditing,
                    onChange: onTextChange, onEndEditing: onEndEditing
                )
            case .bubble(let bubbleText):
                EditableBubbleView(
                    bubbleText: bubbleText, isEditing: isEditing,
                    onChange: onTextChange, onEndEditing: onEndEditing
                )
            case .shape(let kind):
                ShapeObjectView(kind: kind)
            case .connector(let startID, let endID):
                DynamicConnectorView(
                    startID: startID, endID: endID,
                    allObjects: allObjects
                )
            case .mindNode(let label, let parentID):
                MindNodeView(label: label, parentID: parentID, allObjects: allObjects)
            case .media(let assetID, let mediaKind):
                if mediaKind == .image && assetID != nil {
                    ImageCanvasObjectView(assetID: assetID)
                } else {
                    MediaPlaceholderObjectView(mediaKind: mediaKind)
                }
            case .pdfPage(let pdfURL, let pageIndex):
                if let pdfURL, let url = URL(string: pdfURL) {
                    PDFCanvasObjectView(pdfURL: url, pageIndex: pageIndex)
                } else {
                    MediaPlaceholderObjectView(mediaKind: .file)
                }
            case .handwrittenText(let sourceText, let drawingData, _):
                HandwrittenTextObjectView(sourceText: sourceText, drawingData: drawingData)
            }
        }
        .overlay {
            if isSelected && !isEditing {
                RoundedRectangle(cornerRadius: Brand.cornerS, style: .continuous)
                    .strokeBorder(Brand.aiAccent, lineWidth: isDragging ? 2.5 : 2)
                if let onResize, !isDragging {
                    ResizeHandles(
                        objectSize: object.size.cgSize,
                        onResize: onResize,
                        onResizeStart: onResizeStart
                    )
                }
            }
            if isConnectorStart {
                RoundedRectangle(cornerRadius: Brand.cornerS, style: .continuous)
                    .strokeBorder(Brand.aiBadge.opacity(0.5), lineWidth: 1.5)
                    .scaleEffect(1.05)
            }
        }
        .opacity(isDragging ? 0.92 : 1.0)
        .shadow(color: isDragging ? Brand.aiAccent.opacity(0.15) : .clear, radius: 8, y: 2)
        .rotationEffect(.degrees(object.rotation))
        .zIndex(Double(object.zIndex))
    }
}

// MARK: - AI Card (read-only)

private struct AICardObjectView: View {
    let title: String
    let bodyText: String

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerM) {
            VStack(alignment: .leading, spacing: Brand.spacingS) {
                HStack(spacing: Brand.spacingS) {
                    Text(title).font(Brand.titleFont).foregroundStyle(Brand.inkPrimary)
                    AIBadge()
                }
                Text(bodyText).font(Brand.bodyFont).foregroundStyle(Brand.inkSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(String(localized: "object.aiCard.accessibility")))
    }
}

// MARK: - Shape (read-only)

private struct ShapeObjectView: View {
    let kind: CanvasShapeKind

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let path = shapePath(in: rect)
            context.stroke(path, with: .color(Brand.inkPrimary.opacity(Brand.handleStrokeOpacity)), lineWidth: 2)
        }
        .accessibilityLabel(Text(String(localized: "object.shape.accessibility")))
    }

    private func shapePath(in rect: CGRect) -> Path {
        switch kind {
        case .rectangle: return Path(rect)
        case .roundedRectangle: return Path(roundedRect: rect, cornerRadius: Brand.cornerS)
        case .ellipse: return Path(ellipseIn: rect)
        case .diamond:
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            p.closeSubpath()
            return p
        case .arrow:
            var p = Path()
            p.move(to: CGPoint(x: rect.minX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.midY))
            return p
        case .line:
            var p = Path()
            p.move(to: CGPoint(x: rect.minX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            return p
        }
    }
}

// MARK: - Media Placeholder

private struct MediaPlaceholderObjectView: View {
    let mediaKind: MediaKind

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerS) {
            VStack(spacing: Brand.spacingS) {
                Image(systemName: mediaKind == .image ? "photo" : "doc")
                    .font(.system(size: Brand.placeholderIconSize))
                    .foregroundStyle(Brand.inkSecondary)
                Text(mediaKind == .image
                    ? String(localized: "object.image.placeholder")
                    : String(localized: "object.file.placeholder"))
                    .font(Brand.captionFont)
                    .foregroundStyle(Brand.inkSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityLabel(Text(mediaKind == .image
            ? String(localized: "object.image.placeholder")
            : String(localized: "object.file.placeholder")))
    }
}

// MARK: - Handwritten Text (PKDrawing rendered)

private struct HandwrittenTextObjectView: View {
    let sourceText: String
    let drawingData: Data

    var body: some View {
        ZStack {
            if let drawing = try? PKDrawing(data: drawingData), !drawing.strokes.isEmpty {
                Canvas { context, size in
                    let bounds = drawing.bounds
                    guard bounds.width > 0, bounds.height > 0 else { return }
                    let scaleX = size.width / bounds.width
                    let scaleY = size.height / bounds.height
                    let scale = min(scaleX, scaleY)
                    let image = drawing.image(from: bounds, scale: 1.0)
                    let drawSize = CGSize(width: bounds.width * scale, height: bounds.height * scale)
                    let origin = CGPoint(
                        x: (size.width - drawSize.width) / 2,
                        y: (size.height - drawSize.height) / 2
                    )
                    context.draw(Image(uiImage: image), in: CGRect(origin: origin, size: drawSize))
                }
                .accessibilityLabel(Text(String(localized: "object.handwritten.accessibility")))
            } else {
                Text(sourceText)
                    .font(Brand.bodyFont)
                    .foregroundStyle(Brand.inkPrimary)
                    .multilineTextAlignment(.center)
                    .padding(Brand.spacingS)
            }
        }
    }
}

import SwiftUI

/// Routes a CanvasObject to the correct specialized view based on content.
struct CanvasObjectView: View {
    let object: CanvasObject
    let isSelected: Bool
    let isEditing: Bool
    var onTextChange: ((String) -> Void)?
    var onEndEditing: (() -> Void)?
    var onResize: ((CGSize) -> Void)?
    var onResizeStart: (() -> Void)?

    var body: some View {
        Group {
            switch object.content {
            case .aiCard(let title, let body):
                AICardObjectView(title: title, body: body)
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
                ConnectorObjectView(startID: startID, endID: endID)
            case .media(_, let mediaKind):
                MediaPlaceholderObjectView(mediaKind: mediaKind)
            }
        }
        .overlay {
            if isSelected && !isEditing {
                RoundedRectangle(cornerRadius: Brand.cornerS, style: .continuous)
                    .strokeBorder(Brand.aiBadge, lineWidth: 2)
                if let onResize, let onResizeStart {
                    ResizeHandles(
                        objectSize: object.size.cgSize,
                        onResize: onResize,
                        onResizeStart: onResizeStart
                    )
                }
            }
        }
        .rotationEffect(.degrees(object.rotation))
        .zIndex(Double(object.zIndex))
    }
}

// MARK: - AI Card (read-only)

private struct AICardObjectView: View {
    let title: String
    let body: String

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerM) {
            VStack(alignment: .leading, spacing: Brand.spacingS) {
                HStack(spacing: Brand.spacingS) {
                    Text(title).font(Brand.titleFont).foregroundStyle(Brand.inkPrimary)
                    AIBadge()
                }
                Text(body).font(Brand.bodyFont).foregroundStyle(Brand.inkSecondary)
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
            context.stroke(path, with: .color(Brand.inkPrimary.opacity(0.6)), lineWidth: 2)
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

// MARK: - Connector

private struct ConnectorObjectView: View {
    let startID: UUID?
    let endID: UUID?

    var body: some View {
        Rectangle()
            .fill(Brand.inkPrimary.opacity(0.4))
            .frame(height: 2)
            .accessibilityLabel(Text(String(localized: "object.connector.accessibility")))
    }
}

// MARK: - Media Placeholder

private struct MediaPlaceholderObjectView: View {
    let mediaKind: MediaKind

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerS) {
            VStack(spacing: Brand.spacingS) {
                Image(systemName: mediaKind == .image ? "photo" : "doc")
                    .font(.system(size: 28))
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

import SwiftUI

/// Routes a CanvasObject to the correct specialized view based on content.
struct CanvasObjectView: View {
    let object: CanvasObject
    let isSelected: Bool

    var body: some View {
        Group {
            switch object.content {
            case .aiCard(let title, let body):
                AICardObjectView(title: title, body: body)
            case .text(let text):
                TextObjectView(text: text)
            case .stickyNote(let noteText):
                StickyNoteObjectView(noteText: noteText, tint: object.style.tint)
            case .bubble(let bubbleText):
                BubbleObjectView(bubbleText: bubbleText)
            case .shape(let kind):
                ShapeObjectView(kind: kind)
            case .connector(let startID, let endID):
                ConnectorObjectView(startID: startID, endID: endID)
            case .media(_, let mediaKind):
                MediaPlaceholderObjectView(mediaKind: mediaKind)
            }
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: Brand.cornerS, style: .continuous)
                    .strokeBorder(Brand.aiBadge, lineWidth: 2)
            }
        }
        .rotationEffect(.degrees(object.rotation))
        .zIndex(Double(object.zIndex))
    }
}

// MARK: - AI Card

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

// MARK: - Text Box

private struct TextObjectView: View {
    let text: String

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerS) {
            Text(text.isEmpty ? String(localized: "object.text.placeholder") : text)
                .font(Brand.bodyFont)
                .foregroundStyle(text.isEmpty ? Brand.inkSecondary : Brand.inkPrimary)
        }
        .accessibilityLabel(Text(String(localized: "object.textBox.accessibility")))
    }
}

// MARK: - Sticky Note

private struct StickyNoteObjectView: View {
    let noteText: String
    let tint: String?

    var body: some View {
        RoundedRectangle(cornerRadius: Brand.cornerS, style: .continuous)
            .fill(stickyColor)
            .overlay {
                Text(noteText)
                    .font(Brand.captionFont)
                    .foregroundStyle(Brand.inkPrimary)
                    .padding(Brand.spacingS)
            }
            .shadow(color: Brand.glassShadow, radius: 6, y: 2)
            .accessibilityLabel(Text(String(localized: "object.stickyNote.accessibility")))
    }

    private var stickyColor: Color {
        switch tint {
        case "stickyPink": return Color.pink.opacity(0.2)
        case "stickyGreen": return Color.green.opacity(0.2)
        default: return Color.yellow.opacity(0.25)
        }
    }
}

// MARK: - Bubble

private struct BubbleObjectView: View {
    let bubbleText: String

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerL) {
            Text(bubbleText)
                .font(Brand.titleFont)
                .foregroundStyle(Brand.inkPrimary)
                .frame(maxWidth: .infinity)
        }
        .clipShape(Ellipse())
        .accessibilityLabel(Text(String(localized: "object.bubble.accessibility")))
    }
}

// MARK: - Shape

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

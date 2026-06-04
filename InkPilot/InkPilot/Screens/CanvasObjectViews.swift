import SwiftUI

/// Routes a CanvasObject to the correct specialized view based on its type.
struct CanvasObjectView: View {
    let object: CanvasObject
    let isSelected: Bool

    var body: some View {
        Group {
            switch object.type {
            case .aiCard:
                AICardObjectView(object: object)
            case .textBox:
                TextObjectView(object: object)
            case .stickyNote:
                StickyNoteObjectView(object: object)
            case .bubble:
                BubbleObjectView(object: object)
            case .shape:
                ShapeObjectView(object: object)
            case .connector:
                ConnectorObjectView(object: object)
            case .image, .file:
                MediaPlaceholderObjectView(object: object)
            }
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: Brand.cornerS, style: .continuous)
                    .strokeBorder(Brand.aiBadge, lineWidth: 2)
            }
        }
    }
}

// MARK: - AI Card

struct AICardObjectView: View {
    let object: CanvasObject

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerM) {
            VStack(alignment: .leading, spacing: Brand.spacingS) {
                HStack(spacing: Brand.spacingS) {
                    Text(object.title)
                        .font(Brand.titleFont)
                        .foregroundStyle(Brand.inkPrimary)
                    AIBadge()
                }
                Text(object.body)
                    .font(Brand.bodyFont)
                    .foregroundStyle(Brand.inkSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(String(localized: "object.aiCard.accessibility")))
    }
}

// MARK: - Text Box

struct TextObjectView: View {
    let object: CanvasObject

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerS) {
            VStack(alignment: .leading, spacing: Brand.spacingXS) {
                if !object.title.isEmpty {
                    Text(object.title)
                        .font(Brand.bodyFont.weight(.semibold))
                        .foregroundStyle(Brand.inkPrimary)
                }
                if !object.body.isEmpty {
                    Text(object.body)
                        .font(Brand.bodyFont)
                        .foregroundStyle(Brand.inkSecondary)
                }
            }
        }
        .accessibilityLabel(Text(String(localized: "object.textBox.accessibility")))
    }
}

// MARK: - Sticky Note

struct StickyNoteObjectView: View {
    let object: CanvasObject

    var body: some View {
        RoundedRectangle(cornerRadius: Brand.cornerS, style: .continuous)
            .fill(stickyColor)
            .overlay {
                VStack(alignment: .leading, spacing: Brand.spacingXS) {
                    if !object.title.isEmpty {
                        Text(object.title)
                            .font(Brand.bodyFont.weight(.semibold))
                            .foregroundStyle(Brand.inkPrimary)
                    }
                    if !object.body.isEmpty {
                        Text(object.body)
                            .font(Brand.captionFont)
                            .foregroundStyle(Brand.inkSecondary)
                    }
                }
                .padding(Brand.spacingS)
            }
            .shadow(color: Brand.glassShadow, radius: 6, y: 2)
            .accessibilityLabel(Text(String(localized: "object.stickyNote.accessibility")))
    }

    private var stickyColor: Color {
        switch object.style.tint {
        case "stickyPink": return Color.pink.opacity(0.2)
        case "stickyGreen": return Color.green.opacity(0.2)
        default: return Color.yellow.opacity(0.25)
        }
    }
}

// MARK: - Bubble

struct BubbleObjectView: View {
    let object: CanvasObject

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerL) {
            VStack(spacing: Brand.spacingS) {
                Text(object.title)
                    .font(Brand.titleFont)
                    .foregroundStyle(Brand.inkPrimary)
                Text(object.body)
                    .font(Brand.captionFont)
                    .foregroundStyle(Brand.inkSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .clipShape(Ellipse())
        .accessibilityLabel(Text(String(localized: "object.bubble.accessibility")))
    }
}

// MARK: - Shape

struct ShapeObjectView: View {
    let object: CanvasObject

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let path = shapePath(in: rect)
            context.stroke(path, with: .color(Brand.inkPrimary.opacity(0.6)), lineWidth: 2)
        }
        .accessibilityLabel(Text(String(localized: "object.shape.accessibility")))
    }

    private func shapePath(in rect: CGRect) -> Path {
        switch object.shapeKind {
        case .rectangle:
            return Path(rect)
        case .roundedRectangle:
            return Path(roundedRect: rect, cornerRadius: Brand.cornerS)
        case .ellipse:
            return Path(ellipseIn: rect)
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
        case .line, .none:
            var p = Path()
            p.move(to: CGPoint(x: rect.minX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            return p
        }
    }
}

// MARK: - Connector

struct ConnectorObjectView: View {
    let object: CanvasObject

    var body: some View {
        Rectangle()
            .fill(Brand.inkPrimary.opacity(0.4))
            .frame(height: 2)
            .accessibilityLabel(Text(String(localized: "object.connector.accessibility")))
    }
}

// MARK: - Media Placeholder

struct MediaPlaceholderObjectView: View {
    let object: CanvasObject

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerS) {
            VStack(spacing: Brand.spacingS) {
                Image(systemName: object.type == .image ? "photo" : "doc")
                    .font(.system(size: 28))
                    .foregroundStyle(Brand.inkSecondary)
                Text(object.title)
                    .font(Brand.captionFont)
                    .foregroundStyle(Brand.inkSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityLabel(Text(object.title))
    }
}

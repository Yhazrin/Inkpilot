import SwiftUI

/// Dynamic connector that draws a line between two linked objects.
/// Updates in real-time when either object moves.
struct DynamicConnectorView: View {
    let startID: UUID?
    let endID: UUID?
    let allObjects: [CanvasObject]

    var body: some View {
        if let startPos = resolvedStart, let endPos = resolvedEnd {
            Canvas { context, _ in
                let start = CGPoint(x: startPos.x, y: startPos.y)
                let end = CGPoint(x: endPos.x, y: endPos.y)

                // Draw curved connector line
                let midX = (start.x + end.x) / 2
                let control1 = CGPoint(x: midX, y: start.y)
                let control2 = CGPoint(x: midX, y: end.y)

                var path = Path()
                path.move(to: start)
                path.addCurve(to: end, control1: control1, control2: control2)

                context.stroke(path, with: .color(Brand.inkPrimary.opacity(0.5)), lineWidth: 1.5)

                // Draw small circles at endpoints
                let dotSize: CGFloat = 4
                context.fill(
                    Path(ellipseIn: CGRect(x: start.x - dotSize/2, y: start.y - dotSize/2, width: dotSize, height: dotSize)),
                    with: .color(Brand.inkPrimary.opacity(0.6))
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: end.x - dotSize/2, y: end.y - dotSize/2, width: dotSize, height: dotSize)),
                    with: .color(Brand.inkPrimary.opacity(0.6))
                )
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        } else {
            // Fallback: static line if objects not found
            Rectangle()
                .fill(Brand.inkPrimary.opacity(0.3))
                .frame(height: 1.5)
        }
    }

    /// Resolve start position: center of start object, or connector's own position.
    private var resolvedStart: CGPoint? {
        guard let startID,
              let obj = allObjects.first(where: { $0.id == startID }) else { return nil }
        return CGPoint(
            x: obj.worldPosition.x + obj.size.width,
            y: obj.worldPosition.y + obj.size.height / 2
        )
    }

    /// Resolve end position: center-left of end object.
    private var resolvedEnd: CGPoint? {
        guard let endID,
              let obj = allObjects.first(where: { $0.id == endID }) else { return nil }
        return CGPoint(
            x: obj.worldPosition.x,
            y: obj.worldPosition.y + obj.size.height / 2
        )
    }
}

/// A mind map node with a label and optional parent connector.
struct MindNodeView: View {
    let label: String
    let parentID: UUID?
    let allObjects: [CanvasObject]

    var body: some View {
        VStack(spacing: 0) {
            // Parent connector line (drawn above the node)
            if parentID != nil {
                parentConnector
            }

            // Node body
            GlassCard(cornerRadius: Brand.cornerL) {
                Text(label.isEmpty ? String(localized: "object.mindNode.placeholder") : label)
                    .font(Brand.bodyFont.weight(.medium))
                    .foregroundStyle(Brand.inkPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(String(localized: "object.mindNode.accessibility")))
    }

    /// Draw a connector line from parent to this node.
    @ViewBuilder
    private var parentConnector: some View {
        if let parentID,
           let parent = allObjects.first(where: { $0.id == parentID }) {
            let parentCenter = CGPoint(
                x: parent.worldPosition.x + parent.size.width / 2,
                y: parent.worldPosition.y + parent.size.height
            )
            Canvas { context, _ in
                let start = CGPoint(x: parentCenter.x, y: parentCenter.y)
                let end = CGPoint(x: 0, y: 0) // Will be positioned by parent
                var path = Path()
                path.move(to: start)
                path.addLine(to: end)
                context.stroke(path, with: .color(Brand.inkPrimary.opacity(0.3)), lineWidth: 1)
            }
            .frame(height: 20)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

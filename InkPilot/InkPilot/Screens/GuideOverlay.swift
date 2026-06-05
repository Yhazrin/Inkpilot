import SwiftUI

/// Renders alignment guide lines during object drag.
struct GuideOverlay: View {

    // MARK: - Properties
    let guides: [GuideLine]
    let transform: CanvasTransform

    var body: some View {
        Canvas { context, size in
            for guide in guides {
                let screenPos = transform.worldToScreen(
                    guide.orientation == .vertical
                        ? CGPoint(x: guide.position, y: guide.start)
                        : CGPoint(x: guide.start, y: guide.position)
                )
                let screenEnd = transform.worldToScreen(
                    guide.orientation == .vertical
                        ? CGPoint(x: guide.position, y: guide.end)
                        : CGPoint(x: guide.end, y: guide.position)
                )

                var path = Path()
                path.move(to: screenPos)
                path.addLine(to: screenEnd)
                context.stroke(path, with: .color(Brand.aiAccent.opacity(Brand.selectionBorderOpacity)), lineWidth: Brand.thinStrokeWidth)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

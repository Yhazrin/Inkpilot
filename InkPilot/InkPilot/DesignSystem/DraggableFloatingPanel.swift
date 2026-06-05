import SwiftUI

/// A floating panel that the user can drag to one of 8 anchor positions.
///
/// **Interaction**
/// 1. User presses anywhere on the panel (or its padding ring).
/// 2. The panel content fades out and a small glass ball appears at the
///    touch point.
/// 3. The ball follows the finger.
/// 4. On release, the ball snaps to the nearest anchor (corners and edge
///    midpoints of the canvas) and the panel content fades back in at the
///    new position with a spring animation.
///
/// Tapping without dragging (under `dragThreshold` movement) does not
/// trigger the drag, so the inner buttons of the panel still work as
/// normal taps.
struct DraggableFloatingPanel<Content: View>: View {
    @Binding var position: FloatingPanelPosition
    let ballIcon: String
    let edgeInset: CGFloat
    @ViewBuilder let content: () -> Content

    @State private var isDragging = false
    @State private var ballLocation: CGPoint = .zero

    private let ballSize: CGFloat = 48
    private let dragThreshold: CGFloat = 6

    init(
        position: Binding<FloatingPanelPosition>,
        ballIcon: String = "line.3.horizontal",
        edgeInset: CGFloat = 24,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._position = position
        self.ballIcon = ballIcon
        self.edgeInset = edgeInset
        self.content = content
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: position.alignment) {
                Color.clear
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)

                content()
                    .padding(edgeInset)
                    .opacity(isDragging ? 0 : 1)
                    .contentShape(Rectangle())
                    .simultaneousGesture(dragGesture(in: geo))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if isDragging {
                ball
                    .position(ballLocation)
                    .transition(MotionTokens.scaleFade)
            }
        }
        .coordinateSpace(name: "canvas")
        .animation(MotionTokens.panelDrag, value: isDragging)
        .animation(MotionTokens.panelSettle, value: position)
    }

    // MARK: - Ball

    private var ball: some View {
        Image(systemName: ballIcon)
            .font(.system(size: Brand.panelTitleFontSize, weight: .semibold))
            .foregroundStyle(Brand.inkPrimary)
            .frame(width: ballSize, height: ballSize)
            .background {
                Circle().fill(.ultraThinMaterial)
            }
            .overlay {
                Circle().strokeBorder(Brand.glassBorder, lineWidth: Brand.glassBorderWidth)
            }
            .shadow(color: Brand.glassShadow, radius: Brand.shadowRadius, y: Brand.shadowY)
    }

    // MARK: - Drag

    private func dragGesture(in geo: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: dragThreshold, coordinateSpace: .named("canvas"))
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                }
                ballLocation = value.location
            }
            .onEnded { value in
                position = nearestAnchor(to: value.location, in: geo.size)
                isDragging = false
            }
    }

    // MARK: - Snap

    private func nearestAnchor(to point: CGPoint, in size: CGSize) -> FloatingPanelPosition {
        var best: FloatingPanelPosition = position
        var bestDist: CGFloat = .infinity
        for (candidate, anchor) in snapAnchors(in: size) {
            let dx = point.x - anchor.x
            let dy = point.y - anchor.y
            let dist = dx * dx + dy * dy
            if dist < bestDist {
                bestDist = dist
                best = candidate
            }
        }
        return best
    }

    /// The 8 snap targets — corners and edge midpoints, all inset by
    /// `edgeInset` from the canvas edge so the panel doesn't kiss the
    /// screen bezel.
    private func snapAnchors(in size: CGSize) -> [(FloatingPanelPosition, CGPoint)] {
        let i = edgeInset
        return [
            (.topCenter,    CGPoint(x: size.width / 2, y: i)),
            (.topLeft,      CGPoint(x: i, y: i)),
            (.topRight,     CGPoint(x: size.width - i, y: i)),
            (.middleLeft,   CGPoint(x: i, y: size.height / 2)),
            (.middleRight,  CGPoint(x: size.width - i, y: size.height / 2)),
            (.bottomCenter, CGPoint(x: size.width / 2, y: size.height - i)),
            (.bottomLeft,   CGPoint(x: i, y: size.height - i)),
            (.bottomRight,  CGPoint(x: size.width - i, y: size.height - i)),
        ]
    }
}

import SwiftUI

/// Renders all canvas objects at their world positions.
/// Supports selection and drag-to-move when Select tool is active.
/// Materializes AI cards from sourceAnchor with travel animation.
struct CanvasObjectLayer: View {
    let objects: [CanvasObject]
    let selectedID: UUID?
    let isSelectToolActive: Bool
    let sourceAnchor: CGPoint?
    var onSelect: (UUID) -> Void
    var onMove: (UUID, CGPointCodable) -> Void

    /// Per-object drag start positions. Captured on the first
    /// `onChanged` of a drag gesture so the drag stays anchored to
    /// the object's position at drag start, not its position after
    /// the previous frame's `onMove` mutated it. Cleared on
    /// `onEnded`/`onCancelled`.
    @State private var dragStartPositions: [UUID: CGPoint] = [:]

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(objects) { object in
                CanvasObjectView(object: object, isSelected: object.id == selectedID)
                    .frame(width: object.size.cgSize.width, height: object.size.cgSize.height)
                    .position(object.worldPosition.cgPoint)
                    .transition(materializationTransition(for: object))
                    .gesture(
                        isSelectToolActive
                            ? dragGesture(for: object)
                            : nil
                    )
                    .onTapGesture {
                        if isSelectToolActive { onSelect(object.id) }
                    }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: objects.count)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(isSelectToolActive)
    }

    // MARK: - Drag gesture (caches start position per object)

    /// Drag gesture with stable start-anchored translation.
    ///
    /// We cannot read the object's original `worldPosition` inside
    /// `onChanged` because `onMove` mutates that property on every
    /// frame, so `value.translation` (which is cumulative from the
    /// drag start) would be re-applied on top of the just-moved
    /// position, accelerating the object off-screen. Instead we cache
    /// `worldPosition` the first time the gesture fires and recompute
    /// the target as `start + translation` for every subsequent
    /// frame.
    private func dragGesture(for object: CanvasObject) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                let start = dragStartPositions[object.id]
                    ?? object.worldPosition.cgPoint
                if dragStartPositions[object.id] == nil {
                    dragStartPositions[object.id] = start
                }
                let newPos = CGPointCodable(
                    x: start.x + value.translation.width,
                    y: start.y + value.translation.height
                )
                onMove(object.id, newPos)
            }
            .onEnded { _ in
                dragStartPositions.removeValue(forKey: object.id)
            }
    }

    // MARK: - Materialization transition for AI cards

    private func materializationTransition(for object: CanvasObject) -> AnyTransition {
        guard object.source == .ai, let anchor = sourceAnchor else {
            return .asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .opacity
            )
        }
        let travel = CGSize(
            width: anchor.x - object.worldPosition.cgPoint.x,
            height: anchor.y - object.worldPosition.cgPoint.y
        )
        return .asymmetric(
            insertion: .modifier(
                active: MaterializeModifier(progress: 0, travel: travel),
                identity: MaterializeModifier(progress: 1, travel: travel)
            ),
            removal: .opacity
        )
    }
}

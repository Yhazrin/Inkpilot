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

    // MARK: - Drag gesture (start + translation, not value.location)

    private func dragGesture(for object: CanvasObject) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                let startPos = object.worldPosition.cgPoint
                let newPos = CGPointCodable(
                    x: startPos.x + value.translation.width,
                    y: startPos.y + value.translation.height
                )
                onMove(object.id, newPos)
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

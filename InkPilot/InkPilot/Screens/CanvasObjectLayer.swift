import SwiftUI

/// Renders all canvas objects at their world positions, transformed
/// to screen space via CanvasTransform. Supports selection, drag-to-move,
/// editing, and sourceAnchor-based materialization.
struct CanvasObjectLayer: View {
    let objects: [CanvasObject]
    let selectedID: UUID?
    let editingID: UUID?
    let isSelectToolActive: Bool
    let sourceAnchor: CGPoint?
    let transform: CanvasTransform
    var onSelect: (UUID) -> Void
    var onBeginEditing: (UUID) -> Void
    var onEndEditing: () -> Void
    var onTextChange: (UUID, String) -> Void
    var onMove: (UUID, CGPointCodable) -> Void

    @State private var dragStartPositions: [UUID: CGPoint] = [:]

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(objects) { object in
                let screenPos = transform.worldToScreen(object.worldPosition.cgPoint)
                let screenSize = transform.worldToScreenSize(object.size.cgSize)
                let isEditing = object.id == editingID

                CanvasObjectView(
                    object: object,
                    isSelected: object.id == selectedID,
                    isEditing: isEditing,
                    onTextChange: { newText in onTextChange(object.id, newText) },
                    onEndEditing: onEndEditing
                )
                .frame(width: screenSize.width, height: screenSize.height)
                .position(screenPos)
                .transition(materializationTransition(for: object))
                .gesture(
                    isSelectToolActive && !isEditing
                        ? dragGesture(for: object)
                        : nil
                )
                .onTapGesture(count: 2) {
                    if isSelectToolActive { onBeginEditing(object.id) }
                }
                .onTapGesture(count: 1) {
                    if isSelectToolActive && !isEditing { onSelect(object.id) }
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: objects.count)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Always allow hit testing — PencilKit is pencilOnly so fingers
        // are free to interact with objects. Tool selection gates what
        // happens (select/drag vs nothing), not whether touches pass through.
    }

    // MARK: - Drag gesture (world-space, caches start position)

    private func dragGesture(for object: CanvasObject) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                let start = dragStartPositions[object.id]
                    ?? object.worldPosition.cgPoint
                if dragStartPositions[object.id] == nil {
                    dragStartPositions[object.id] = start
                }
                let worldTranslation = CGSize(
                    width: value.translation.width / transform.scale,
                    height: value.translation.height / transform.scale
                )
                let newPos = CGPointCodable(
                    x: start.x + worldTranslation.width,
                    y: start.y + worldTranslation.height
                )
                onMove(object.id, newPos)
            }
            .onEnded { _ in
                dragStartPositions.removeValue(forKey: object.id)
            }
    }

    // MARK: - Materialization transition

    private func materializationTransition(for object: CanvasObject) -> AnyTransition {
        guard object.source == .ai, let anchor = sourceAnchor else {
            return .asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .opacity
            )
        }
        let screenAnchor = transform.worldToScreen(anchor)
        let screenPos = transform.worldToScreen(object.worldPosition.cgPoint)
        let travel = CGSize(
            width: screenAnchor.x - screenPos.x,
            height: screenAnchor.y - screenPos.y
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

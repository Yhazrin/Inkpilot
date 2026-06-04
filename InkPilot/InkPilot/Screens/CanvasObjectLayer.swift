import SwiftUI

/// Renders all canvas objects at their WORLD positions.
/// The entire layer is scaled + offset to match PencilKit's zoom/pan,
/// so objects stay aligned with ink during zoom.
struct CanvasObjectLayer: View {
    let objects: [CanvasObject]
    let selectedID: UUID?
    let editingID: UUID?
    let isSelectToolActive: Bool
    let isConnectorToolActive: Bool
    let connectorStartID: UUID?
    let sourceAnchor: CGPoint?
    let transform: CanvasTransform
    var onSelect: (UUID) -> Void
    var onConnectorTap: (UUID) -> Void
    var onBeginEditing: (UUID) -> Void
    var onEndEditing: () -> Void
    var onTextChange: (UUID, String) -> Void
    var onMove: (UUID, CGPointCodable) -> Void
    var onResize: (UUID, CGSizeCodable) -> Void

    @State private var dragStartPositions: [UUID: CGPoint] = [:]

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(objects) { object in
                let isEditing = object.id == editingID

                CanvasObjectView(
                    object: object,
                    isSelected: object.id == selectedID,
                    isEditing: isEditing,
                    onTextChange: { newText in onTextChange(object.id, newText) },
                    onEndEditing: onEndEditing,
                    onResize: { newSize in
                        // newSize is in screen space — convert to world
                        let worldSize = CGSizeCodable(
                            width: newSize.width / transform.scale,
                            height: newSize.height / transform.scale
                        )
                        onResize(object.id, worldSize)
                    }
                )
                // Render at WORLD size + WORLD position.
                // The layer-level scaleEffect + offset will transform to screen.
                .frame(
                    width: object.size.cgSize.width,
                    height: object.size.cgSize.height
                )
                .position(object.worldPosition.cgPoint)
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
                    if isConnectorToolActive {
                        onConnectorTap(object.id)
                    } else if isSelectToolActive && !isEditing {
                        onSelect(object.id)
                    }
                }
            }
        }
        // Scale the entire layer from top-left to match PencilKit zoom.
        // Offset matches PencilKit's contentOffset.
        .scaleEffect(transform.scale, anchor: .topLeading)
        .offset(x: transform.offset.width, y: transform.offset.height)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: objects.count)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
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
                // Screen translation → world translation
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

    // MARK: - Materialization transition (world-space travel)

    private func materializationTransition(for object: CanvasObject) -> AnyTransition {
        guard object.source == .ai, let anchor = sourceAnchor else {
            return .asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .opacity
            )
        }
        // Travel vector in world space (the layer is already scaled)
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

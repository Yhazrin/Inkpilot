import SwiftUI

/// Renders all canvas objects at their WORLD positions.
/// Supports multi-selection, group selection, drag-to-move, resize,
/// and sourceAnchor-based materialization.
struct CanvasObjectLayer: View {
    let objects: [CanvasObject]
    let selectedIDs: Set<UUID>
    let editingID: UUID?
    let isSelectToolActive: Bool
    let isConnectorToolActive: Bool
    let connectorStartID: UUID?
    let sourceAnchor: CGPoint?
    let transform: CanvasTransform
    var onSelect: (UUID) -> Void
    var onToggleSelection: (UUID) -> Void
    var onGroupTap: (UUID?) -> Void
    var onConnectorTap: (UUID) -> Void
    var onBeginEditing: (UUID) -> Void
    var onEndEditing: () -> Void
    var onTextChange: (UUID, String) -> Void
    var onMove: (UUID, CGPointCodable) -> Void
    var onMoveSelected: (CGPointCodable) -> Void
    var onDragStart: () -> Void
    var onDragEnd: () -> Void
    var onResize: (UUID, CGSizeCodable) -> Void
    var onResizeStart: (UUID) -> Void

    @State private var dragStartPositions: [UUID: CGPoint] = [:]
    @State private var multiDragStartPositions: [UUID: CGPoint] = [:]
    @State private var isDraggingMulti = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(objects) { object in
                let isEditing = object.id == editingID
                let isSelected = selectedIDs.contains(object.id)

                CanvasObjectView(
                    object: object,
                    isSelected: isSelected,
                    isEditing: isEditing,
                    isDragging: isDraggingMulti && selectedIDs.contains(object.id),
                    allObjects: objects,
                    onTextChange: { newText in onTextChange(object.id, newText) },
                    onEndEditing: onEndEditing,
                    onResize: { newSize in
                        let worldSize = CGSizeCodable(
                            width: newSize.width / transform.scale,
                            height: newSize.height / transform.scale
                        )
                        onResize(object.id, worldSize)
                    },
                    onResizeStart: { onResizeStart(object.id) }
                )
                .frame(
                    width: object.size.cgSize.width,
                    height: object.size.cgSize.height
                )
                .position(object.worldPosition.cgPoint)
                .transition(materializationTransition(for: object))
                .gesture(
                    isSelectToolActive && !isEditing
                        ? objectDragGesture(for: object)
                        : nil
                )
                .onTapGesture(count: 2) {
                    if isSelectToolActive { onBeginEditing(object.id) }
                }
                .onTapGesture(count: 1) {
                    if isConnectorToolActive {
                        onConnectorTap(object.id)
                    } else if isSelectToolActive && !isEditing {
                        handleTap(on: object)
                    }
                }
            }
        }
        .scaleEffect(transform.scale, anchor: .topLeading)
        .offset(x: transform.offset.width, y: transform.offset.height)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: objects.count)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    // MARK: - Tap handling (group-aware)

    private func handleTap(on object: CanvasObject) {
        if let groupID = object.groupID {
            // Tap grouped object → select entire group
            onGroupTap(groupID)
        } else {
            onSelect(object.id)
        }
    }

    // MARK: - Drag gesture (multi-select aware)

    private func objectDragGesture(for object: CanvasObject) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                // On first frame: snapshot positions for all selected objects
                if !isDraggingMulti {
                    isDraggingMulti = true
                    onDragStart()
                    // Cache start positions for all selected objects
                    for id in selectedIDs {
                        if let obj = objects.first(where: { $0.id == id }) {
                            multiDragStartPositions[id] = obj.worldPosition.cgPoint
                        }
                    }
                    // If tapped object not in selection, drag just it
                    if !selectedIDs.contains(object.id) {
                        multiDragStartPositions = [object.id: object.worldPosition.cgPoint]
                    }
                }

                let worldDelta = CGSize(
                    width: value.translation.width / transform.scale,
                    height: value.translation.height / transform.scale
                )

                // Move all objects in the drag set
                for (id, startPos) in multiDragStartPositions {
                    let newPos = CGPointCodable(
                        x: startPos.x + worldDelta.width,
                        y: startPos.y + worldDelta.height
                    )
                    onMove(id, newPos)
                }
            }
            .onEnded { _ in
                isDraggingMulti = false
                multiDragStartPositions.removeAll()
                onDragEnd()
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

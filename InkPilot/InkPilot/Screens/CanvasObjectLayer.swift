import SwiftUI

/// Renders all canvas objects at their world positions.
/// Supports selection and drag-to-move when Select tool is active.
struct CanvasObjectLayer: View {
    let objects: [CanvasObject]
    let selectedID: UUID?
    let isSelectToolActive: Bool
    var onSelect: (UUID) -> Void
    var onMove: (UUID, CGPointCodable) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(objects) { object in
                CanvasObjectView(object: object, isSelected: object.id == selectedID)
                    .frame(width: object.size.cgSize.width, height: object.size.cgSize.height)
                    .position(object.worldPosition.cgPoint)
                    .onTapGesture {
                        onSelect(object.id)
                    }
                    .gesture(
                        isSelectToolActive
                            ? DragGesture()
                                .onChanged { value in
                                    onMove(object.id, CGPointCodable(
                                        x: value.location.x,
                                        y: value.location.y
                                    ))
                                }
                            : nil
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: objects.count)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(isSelectToolActive)
    }
}

import SwiftUI

// MARK: - CanvasView helper views and utilities

extension CanvasView {

    // MARK: - Selection Layer

    @ViewBuilder
    var selectionLayer: some View {
        if viewModel.useLasso {
            LassoSelectionLayer(
                isActive: true,
                transform: viewModel.canvasTransform,
                lassoPoints: $viewModel.lassoPoints,
                onLassoComplete: { points in viewModel.selectObjectsInLasso(points) }
            )
        } else {
            SelectionMarqueeLayer(
                isActive: true,
                transform: viewModel.canvasTransform,
                marqueeStart: $marqueeStart,
                marqueeEnd: $marqueeEnd,
                onMarqueeSelect: { rect in selectObjectsInRect(rect) }
            )
        }
    }

    func selectObjectsInRect(_ worldRect: CGRect) {
        let ids = viewModel.canvasObjects.filter { obj in
            let objRect = CGRect(
                x: obj.worldPosition.x, y: obj.worldPosition.y,
                width: obj.size.width, height: obj.size.height
            )
            return worldRect.intersects(objRect)
        }.map(\.id)
        if !ids.isEmpty { viewModel.selection.selectObjects(Set(ids)) }
    }

    // MARK: - Tool Mode Hint

    func toolModeHint(_ text: String) -> some View {
        Text(text)
            .font(Brand.captionFont)
            .foregroundStyle(Brand.inkTertiary)
            .padding(.horizontal, Brand.spacingM)
            .padding(.vertical, Brand.spacingS)
            .background(Capsule().fill(.ultraThinMaterial))
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, Brand.chromeBottomOffset)
    }

    // MARK: - Empty Canvas Hint

    var emptyCanvasHint: some View {
        VStack(spacing: Brand.spacingM) {
            Image(systemName: "pencil.and.outline")
                .font(.system(size: Brand.emptyHintIconSize))
                .foregroundStyle(Brand.inkTertiary)

            Text(String(localized: "canvas.empty.hint"))
                .font(Brand.titleFont)
                .foregroundStyle(Brand.inkTertiary)
                .multilineTextAlignment(.center)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .transition(MotionTokens.fadeInOut)
        .animation(MotionTokens.emptyHintFade, value: viewModel.drawing.strokes.isEmpty)
    }
}

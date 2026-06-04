import SwiftUI

/// Top floating toolbar extracted from CanvasView.
struct CanvasToolbar: View {
    let viewModel: CanvasViewModel

    var body: some View {
        FloatingToolbar(
            selectedTool: .init(
                get: { viewModel.selectedTool },
                set: { viewModel.selectedTool = $0 }
            ),
            canUndo: viewModel.history.canUndo,
            canRedo: viewModel.history.canRedo,
            onUndo: { viewModel.undo() },
            onRedo: { viewModel.redo() },
            onAITap: { viewModel.requestSuggestion() },
            onShapeTap: {
                viewModel.isShapePaletteVisible.toggle()
                viewModel.isMediaPaletteVisible = false
            },
            onMediaTap: {
                viewModel.isMediaPaletteVisible.toggle()
                viewModel.isShapePaletteVisible = false
            }
        )
    }
}

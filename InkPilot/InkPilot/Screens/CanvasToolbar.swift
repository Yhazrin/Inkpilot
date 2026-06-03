import SwiftUI

/// Top floating toolbar extracted from CanvasView.
/// Composes the FloatingToolbar design system component with canvas tool state.
struct CanvasToolbar: View {
    let viewModel: CanvasViewModel

    var body: some View {
        FloatingToolbar(
            selectedTool: .init(
                get: { viewModel.selectedTool },
                set: { viewModel.selectedTool = $0 }
            ),
            onAITap: { viewModel.requestSuggestion() }
        )
    }
}

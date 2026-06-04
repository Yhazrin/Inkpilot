import SwiftUI

/// Bottom floating prompt capsule extracted from CanvasView.
/// Connects the prompt field to the view model for AI requests.
struct CanvasPromptBar: View {
    let viewModel: CanvasViewModel

    var body: some View {
        FloatingPromptCapsule(
            promptText: .init(
                get: { viewModel.promptText },
                set: { viewModel.promptText = $0 }
            ),
            isThinking: viewModel.isThinking,
            onSubmit: {
                viewModel.requestSuggestion()
                viewModel.promptText = ""
            }
        )
    }
}

import SwiftUI

/// Bottom floating prompt capsule extracted from CanvasView.
/// Connects the prompt field to the view model for AI requests.
struct CanvasPromptBar: View {
    let viewModel: CanvasViewModel

    var body: some View {
        FloatingPromptCapsule(
            promptText: .init(
                get: { viewModel.ai.promptText },
                set: { viewModel.ai.promptText = $0 }
            ),
            isThinking: viewModel.ai.isThinking,
            onSubmit: {
                viewModel.requestSuggestion()
                viewModel.ai.promptText = ""
            }
        )
    }
}

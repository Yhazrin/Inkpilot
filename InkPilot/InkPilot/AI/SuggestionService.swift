import Foundation

/// Rich context passed to the suggestion service describing the current canvas state.
struct CanvasContext {
    let inkText: String
    let promptText: String
    let selectedObjectSummary: String?
    let canvasObjectSummaries: [CanvasObjectSummary]
    let locale: String

    init(
        inkText: String,
        promptText: String = "",
        selectedObjectSummary: String? = nil,
        canvasObjectSummaries: [CanvasObjectSummary] = [],
        locale: String = "en"
    ) {
        self.inkText = inkText
        self.promptText = promptText
        self.selectedObjectSummary = selectedObjectSummary
        self.canvasObjectSummaries = canvasObjectSummaries
        self.locale = locale
    }
}

/// Lightweight summary of a canvas object for AI context.
struct CanvasObjectSummary {
    let type: String
    let title: String
}

/// Protocol for AI suggestion generation.
protocol SuggestionService {
    func generateSuggestion(context: CanvasContext) async throws -> AISuggestionResponse
}

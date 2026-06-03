import Foundation

/// Context passed to the suggestion service describing the current canvas state.
struct CanvasContext {
    let inkText: String
}

/// Protocol for AI suggestion generation.
/// V0.1 uses MockSuggestionService; future versions can swap in OCR + LLM.
protocol SuggestionService {
    func generateSuggestion(context: CanvasContext) async throws -> AISuggestionResponse
}

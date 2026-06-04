import Foundation

/// Returns fixed mock suggestions for the V0.1 demo.
/// Replace with real OCR + LLM service in future versions.
final class MockSuggestionService: SuggestionService {

    func generateSuggestion(context: CanvasContext) async throws -> AISuggestionResponse {
        // Simulate a brief delay for realism
        try await Task.sleep(nanoseconds: 600_000_000)

        return AISuggestionResponse(
            mode: .structure,
            title: String(localized: "suggestion.title.structure"),
            items: [
                AISuggestionItem(
                    id: UUID(),
                    type: .aiCard,
                    title: String(localized: "suggestion.item.targetUsers"),
                    content: String(localized: "suggestion.item.targetUsers.detail")
                ),
                AISuggestionItem(
                    id: UUID(),
                    type: .aiCard,
                    title: String(localized: "suggestion.item.coreWorkflow"),
                    content: String(localized: "suggestion.item.coreWorkflow.detail")
                ),
                AISuggestionItem(
                    id: UUID(),
                    type: .aiCard,
                    title: String(localized: "suggestion.item.mvpFeatures"),
                    content: String(localized: "suggestion.item.mvpFeatures.detail")
                ),
            ]
        )
    }
}

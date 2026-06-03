import SwiftUI
import PencilKit

/// The main state container for the canvas screen.
/// Owns drawing state, tool selection, AI suggestion state, and accepted canvas objects.
@Observable
final class CanvasViewModel {

    // MARK: - Drawing State

    var drawing = PKDrawing()
    var selectedTool: CanvasTool = .pen

    // MARK: - AI Suggestion State (single source of truth)

    var ghostSuggestion: GhostSuggestion?

    // MARK: - AI Panel State

    var isAIPanelExpanded: Bool = false

    // MARK: - Accepted Canvas Objects

    var acceptedCards: [AcceptedCard] = []

    // MARK: - Prompt

    var promptText: String = ""

    // MARK: - Dependencies

    private let suggestionService: SuggestionService

    init(suggestionService: SuggestionService = MockSuggestionService()) {
        self.suggestionService = suggestionService
    }

    // MARK: - Actions

    /// Trigger a mock AI suggestion from the AI button or prompt.
    func requestSuggestion() {
        let context = CanvasContextBuilder.build(from: drawing)
        Task { @MainActor in
            do {
                let response = try await suggestionService.generateSuggestion(context: context)
                withAnimation(.easeInOut(duration: 0.4)) {
                    ghostSuggestion = GhostSuggestion(response: response)
                }
            } catch {
                // V0.1: silently ignore errors from mock service
            }
        }
    }

    /// Accept the current ghost suggestion — turns it into real canvas cards.
    func acceptSuggestion() {
        guard let suggestion = ghostSuggestion else { return }
        let baseX: CGFloat = 400
        let baseY: CGFloat = 300
        let cardSpacing: CGFloat = 140

        let newCards = suggestion.response.items.enumerated().map { index, item in
            AcceptedCard(
                id: UUID(),
                title: item.title,
                body: item.content,
                worldPosition: CGPointCodable(
                    x: baseX,
                    y: baseY + CGFloat(index) * cardSpacing
                ),
                size: CGSizeCodable.defaultCard,
                createdBy: .ai
            )
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            acceptedCards.append(contentsOf: newCards)
            dismissSuggestion()
        }
    }

    /// Dismiss the current ghost suggestion.
    func dismissSuggestion() {
        withAnimation(.easeOut(duration: 0.3)) {
            ghostSuggestion = nil
        }
    }

    /// Clear the canvas drawing.
    func clearCanvas() {
        drawing = PKDrawing()
    }
}

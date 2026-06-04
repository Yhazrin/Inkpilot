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

    /// True between the user triggering AI and the suggestion arriving.
    /// Drives the scan-aura on the canvas.
    var isThinking: Bool = false

    /// The canvas-space point that "birthed" the current ghost suggestion.

    /// The canvas-space point that "birthed" the current ghost suggestion.
    /// In V0.1 this is mocked at a stable location; later it will be derived
    /// from the bounding box of recent ink. Cleared when the ghost is gone.
    var suggestionAnchor: CGPointCodable?

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
        // Pre-set the anchor so the scan aura has somewhere to land
        // before the response arrives.
        let pendingAnchor = SuggestionAnchorResolver.resolve(
            drawing: drawing,
            fallback: CGPoint(x: 520, y: 360)
        )
        withAnimation(.easeInOut(duration: 0.25)) {
            isThinking = true
            suggestionAnchor = CGPointCodable(x: pendingAnchor.x, y: pendingAnchor.y)
        }

        let context = CanvasContextBuilder.build(from: drawing)
        Task { @MainActor in
            do {
                let response = try await suggestionService.generateSuggestion(context: context)
                withAnimation(.easeInOut(duration: 0.4)) {
                    ghostSuggestion = GhostSuggestion(response: response)
                    isThinking = false
                }
            } catch {
                withAnimation(.easeOut(duration: 0.2)) {
                    isThinking = false
                }
            }
        }
    }

    /// Accept the current ghost suggestion — turns it into real canvas cards.
    /// Cards emerge from the suggestion anchor and settle into a column
    /// just below / to the right of it.
    func acceptSuggestion() {
        guard let suggestion = ghostSuggestion else { return }
        let anchorPoint = suggestionAnchor?.cgPoint ?? CGPoint(x: 520, y: 360)

        // Place accepted cards in a vertical column starting at the anchor
        // and offsetting down + slightly right.
        let columnOrigin = CGPoint(
            x: anchorPoint.x + 60,
            y: anchorPoint.y - 80
        )
        let cardSpacing: CGFloat = 150

        let newCards = suggestion.response.items.enumerated().map { index, item in
            AcceptedCard(
                id: UUID(),
                title: item.title,
                body: item.content,
                worldPosition: CGPointCodable(
                    x: columnOrigin.x,
                    y: columnOrigin.y + CGFloat(index) * cardSpacing
                ),
                size: CGSizeCodable.defaultCard,
                createdBy: .ai
            )
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.9)) {
            acceptedCards.append(contentsOf: newCards)
            ghostSuggestion = nil
            // Keep the anchor around briefly so the materialize transition
            // has a source; the AcceptedCardsOverlay reads it for the
            // initial frame, then the cards "forget" it.
            // We clear it on the next runloop tick to avoid stale anchors
            // for a future request.
        }
        // Defer anchor clearing so the materialize animation can sample it.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.suggestionAnchor = nil
        }
    }

    /// Dismiss the current ghost suggestion.
    func dismissSuggestion() {
        withAnimation(.easeOut(duration: 0.3)) {
            ghostSuggestion = nil
        }
        // Clear the anchor a beat later, in case a quick re-trigger races.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.suggestionAnchor = nil
        }
    }

    /// Clear the canvas drawing.
    func clearCanvas() {
        drawing = PKDrawing()
    }
}

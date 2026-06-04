import SwiftUI
import PencilKit

/// The main state container for the canvas screen.
///
/// The view model owns **semantic state only** — drawing, tool
/// selection, AI phase (`isThinking`, `ghostSuggestion`,
/// `suggestionAnchor`), accepted canvas objects, and the prompt text.
///
/// It does **not** own animation timers, completion handlers, or
/// rendering mechanics. The view layer is responsible for any
/// "clear-this-anchor-after-the-exit-motion-completes" timing, and
/// does so via one-shot `Task.sleep` driven by `.onChange`, never via
/// a recursive `DispatchQueue` loop.
@Observable
final class CanvasViewModel {

    // MARK: - Drawing State

    var drawing = PKDrawing()
    var selectedTool: CanvasTool = .pen

    // MARK: - AI Suggestion State (single source of truth)

    /// The current ghost suggestion, if any. `nil` when no suggestion
    /// is on screen.
    var ghostSuggestion: GhostSuggestion?

    /// `true` between the user triggering AI and the suggestion
    /// arriving. Drives the scan-aura on the canvas.
    var isThinking: Bool = false

    /// The canvas-space point that "birthed" the current ghost
    /// suggestion. Set during `requestSuggestion()` and read by the
    /// view layer to position the ghost and the materialize travel
    /// vectors. Cleared by the view layer after the relevant motion
    /// has had a chance to sample it.
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

    /// Trigger an AI suggestion from the AI button or prompt.
    ///
    /// Lifecycle:
    ///   1. Resolve the suggestion anchor synchronously so the scan
    ///      aura has a place to land before the response arrives.
    ///   2. Set `isThinking = true` (drives the scan aura).
    ///   3. Build the canvas context via `CanvasContextBuilder`.
    ///   4. Call the `SuggestionService`.
    ///   5. On response: set `ghostSuggestion` and clear `isThinking`.
    func requestSuggestion() {
        let anchor = SuggestionAnchorResolver.resolve(
            drawing: drawing,
            fallback: SuggestionAnchorResolver.defaultFallback
        )
        withAnimation(.easeInOut(duration: 0.25)) {
            isThinking = true
            suggestionAnchor = CGPointCodable(x: anchor.x, y: anchor.y)
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

    /// Accept the current ghost suggestion.
    ///
    /// Creates `AcceptedCard` objects whose world positions are derived
    /// from the suggestion anchor (a column starting just to the right
    /// of the anchor). The view layer is responsible for clearing
    /// `suggestionAnchor` after the materialize animation has sampled
    /// it.
    func acceptSuggestion() {
        guard let suggestion = ghostSuggestion else { return }
        let anchorPoint = suggestionAnchor?.cgPoint
            ?? SuggestionAnchorResolver.defaultFallback

        // Place accepted cards in a vertical column starting at the
        // anchor, offset right so they don't sit on top of the ink,
        // and offset up so the column fits the available space.
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
        }
    }

    /// Dismiss the current ghost suggestion.
    ///
    /// The view layer is responsible for clearing `suggestionAnchor`
    /// after the exit motion has had a chance to sample it.
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

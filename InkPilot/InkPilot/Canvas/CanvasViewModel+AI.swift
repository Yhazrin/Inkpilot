import SwiftUI
import PencilKit

/// AI suggestion actions for CanvasViewModel.
extension CanvasViewModel {

    func requestSuggestion() {
        let anchor = SuggestionAnchorResolver.resolve(
            drawing: drawing,
            fallback: SuggestionAnchorResolver.defaultFallback
        )
        withAnimation(.easeInOut(duration: 0.25)) {
            ai.isThinking = true
            ai.suggestionAnchor = CGPointCodable(x: anchor.x, y: anchor.y)
        }

        let context = CanvasContextBuilder.build(
            from: drawing,
            canvasObjects: canvasObjects,
            selectedObjectID: selection.primaryID,
            promptText: ai.promptText
        )

        let service = suggestionService
        Task {
            do {
                let response = try await service.generateSuggestion(context: context)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        ai.ghostSuggestion = GhostSuggestion(response: response)
                        ai.isThinking = false
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.2)) {
                        ai.isThinking = false
                    }
                }
            }
        }
    }

    func acceptSuggestion() {
        guard let suggestion = ai.ghostSuggestion else { return }
        let anchorPoint = ai.suggestionAnchor?.cgPoint
            ?? SuggestionAnchorResolver.defaultFallback

        let columnOrigin = CGPoint(x: anchorPoint.x + 60, y: anchorPoint.y - 80)
        let cardSpacing = Brand.aiCardSpacing

        let newObjects = suggestion.response.items.enumerated().map { index, item in
            CanvasObjectFactory.aiCard(
                from: item,
                position: CGPointCodable(
                    x: columnOrigin.x,
                    y: columnOrigin.y + CGFloat(index) * cardSpacing
                )
            )
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.9)) {
            canvasObjects.append(contentsOf: newObjects)
            ai.ghostSuggestion = nil
        }
    }

    func dismissSuggestion() {
        withAnimation(.easeOut(duration: 0.3)) {
            ai.ghostSuggestion = nil
        }
    }
}

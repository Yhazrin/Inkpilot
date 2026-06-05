import SwiftUI
import PencilKit

/// AI suggestion actions for CanvasViewModel.
extension CanvasViewModel {

    func requestSuggestion() {
        let anchor = SuggestionAnchorResolver.resolve(
            drawing: drawing,
            fallback: SuggestionAnchorResolver.defaultFallback
        )
        withAnimation(MotionTokens.thinkingStart) {
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
                    withAnimation(MotionTokens.thinkingResult) {
                        ai.ghostSuggestion = GhostSuggestion(response: response)
                        ai.isThinking = false
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation(MotionTokens.quickFadeOut) {
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
        withAnimation(MotionTokens.suggestionAccept) {
            canvasObjects.append(contentsOf: newObjects)
            ai.ghostSuggestion = nil
        }
    }

    func dismissSuggestion() {
        withAnimation(MotionTokens.thinkingEnd) {
            ai.ghostSuggestion = nil
        }
    }
}

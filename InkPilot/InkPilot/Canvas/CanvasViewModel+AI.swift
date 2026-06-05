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
            let position = CGPointCodable(
                x: columnOrigin.x,
                y: columnOrigin.y + CGFloat(index) * cardSpacing
            )
            return Self.makeObject(for: item, at: position)
        }
        withAnimation(MotionTokens.suggestionAccept) {
            canvasObjects.append(contentsOf: newObjects)
            ai.ghostSuggestion = nil
        }
    }

    /// Dispatch a single `AISuggestionItem` to the right canvas-object
    /// factory based on its `type`. This lets the AI suggest the right
    /// kind of artifact — text box, sticky note, bubble, image, file, etc.
    private static func makeObject(for item: AISuggestionItem, at position: CGPointCodable) -> CanvasObject {
        switch item.type {
        case .aiCard:
            return CanvasObjectFactory.aiCard(from: item, position: position)
        case .textBox:
            return CanvasObjectFactory.textBox(title: item.title, body: item.content, at: position)
        case .stickyNote:
            return CanvasObjectFactory.stickyNote(title: item.title, body: item.content, at: position)
        case .bubble:
            return CanvasObjectFactory.bubble(title: item.title, body: item.content, at: position)
        case .shape:
            return CanvasObjectFactory.shape(kind: .roundedRectangle, at: position)
        case .connector:
            return CanvasObjectFactory.connector(at: position)
        case .image:
            return CanvasObjectFactory.imagePlaceholder(at: position)
        case .file:
            return CanvasObjectFactory.filePlaceholder(at: position)
        }
    }

    func dismissSuggestion() {
        withAnimation(MotionTokens.thinkingEnd) {
            ai.ghostSuggestion = nil
        }
    }
}

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
            isThinking = true
            suggestionAnchor = CGPointCodable(x: anchor.x, y: anchor.y)
        }

        let context = CanvasContextBuilder.build(
            from: drawing,
            canvasObjects: canvasObjects,
            selectedObjectID: selection.primaryID,
            promptText: promptText
        )

        let service = suggestionService
        Task {
            do {
                let response = try await service.generateSuggestion(context: context)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        ghostSuggestion = GhostSuggestion(response: response)
                        isThinking = false
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isThinking = false
                    }
                }
            }
        }
    }

    func acceptSuggestion() {
        guard let suggestion = ghostSuggestion else { return }
        let anchorPoint = suggestionAnchor?.cgPoint
            ?? SuggestionAnchorResolver.defaultFallback

        let columnOrigin = CGPoint(x: anchorPoint.x + 60, y: anchorPoint.y - 80)
        let cardSpacing: CGFloat = 150

        let newObjects = suggestion.response.items.enumerated().map { index, item in
            let position = CGPointCodable(
                x: columnOrigin.x,
                y: columnOrigin.y + CGFloat(index) * cardSpacing
            )
            return Self.makeObject(for: item, at: position)
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.9)) {
            canvasObjects.append(contentsOf: newObjects)
            ghostSuggestion = nil
        }
    }

    /// Dispatches an AI suggestion item to the matching CanvasObject factory
    /// by its declared `type`. Falls back to `aiCard` for unknown types so the
    /// canvas still gets *something* materialised.
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
        withAnimation(.easeOut(duration: 0.3)) {
            ghostSuggestion = nil
        }
    }
}

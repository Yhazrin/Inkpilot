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

        let items = suggestion.response.items.enumerated().map { index, item -> (Int, AISuggestionItem) in
            (index, item)
        }
        let positions = items.map { index, _ in
            CGPointCodable(
                x: columnOrigin.x,
                y: columnOrigin.y + CGFloat(index) * cardSpacing
            )
        }

        // Synthesize handwriting objects in the background, then commit.
        // Non-handwriting items are committed synchronously as before.
        Task { [weak self] in
            guard let self else { return }
            var immediateObjects: [CanvasObject] = []
            var pendingHandwriting: [(CGPointCodable, String)] = []
            for (i, (_, item)) in items.enumerated() {
                let position = positions[i]
                if item.type == .handwrittenText {
                    let text = item.content.isEmpty ? item.title : item.content
                    pendingHandwriting.append((position, text))
                } else {
                    immediateObjects.append(Self.makeObject(for: item, at: position))
                }
            }
            await MainActor.run {
                withAnimation(MotionTokens.suggestionAccept) {
                    self.canvasObjects.append(contentsOf: immediateObjects)
                    self.ai.ghostSuggestion = nil
                }
            }
            for (position, text) in pendingHandwriting {
                let drawing = await Self.renderHandwriting(text: text)
                let object = CanvasObjectFactory.handwrittenText(
                    sourceText: text,
                    drawingData: drawing.dataRepresentation(),
                    at: position
                )
                await MainActor.run {
                    withAnimation(MotionTokens.suggestionAccept) {
                        self.canvasObjects.append(object)
                    }
                }
            }
        }
    }

    /// Render `text` in the active profile's handwriting. Falls back to an
    /// empty drawing when no profile is set yet — in that case the renderer
    /// throws `.noSamples` and the UI shows a plain text placeholder.
    private static func renderHandwriting(text: String) async -> PKDrawing {
        let renderer = LocalHandwritingRenderer()
        do {
            guard let profile = try HandwritingSampleStore.activeProfile() else {
                return PKDrawing()
            }
            return try await renderer.synthesize(
                text: text,
                profileID: profile.id,
                bounds: HandwritingSynthesisDefaults.cardBounds
            )
        } catch {
            return PKDrawing()
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
        case .handwrittenText:
            // Synthesized asynchronously in acceptSuggestion's Task — never here.
            return CanvasObjectFactory.handwrittenText(
                sourceText: item.content.isEmpty ? item.title : item.content,
                drawingData: Data(),
                at: position
            )
        }
    }

    func dismissSuggestion() {
        withAnimation(MotionTokens.thinkingEnd) {
            ai.ghostSuggestion = nil
        }
    }
}

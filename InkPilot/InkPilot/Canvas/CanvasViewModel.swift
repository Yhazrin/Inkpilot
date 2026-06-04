import SwiftUI
import PencilKit

/// The main state container for the canvas screen.
@Observable
final class CanvasViewModel {

    // MARK: - Drawing State

    var drawing = PKDrawing()
    var selectedTool: CanvasTool = .pen

    // MARK: - Viewport / Transform

    /// The current canvas viewport transform (zoom + pan).
    /// Synced from PencilKit's UIScrollView via the coordinator.
    var canvasTransform: CanvasTransform = .identity

    // MARK: - Canvas Objects

    var canvasObjects: [CanvasObject] = []
    var selectedObjectID: UUID?

    // MARK: - AI Suggestion State

    var ghostSuggestion: GhostSuggestion?
    var isThinking: Bool = false
    var suggestionAnchor: CGPointCodable?

    // MARK: - AI Panel State

    var isAIPanelExpanded: Bool = false

    // MARK: - Secondary Palette State

    var isShapePaletteVisible: Bool = false
    var isMediaPaletteVisible: Bool = false

    // MARK: - Prompt

    var promptText: String = ""

    // MARK: - Dependencies

    private let suggestionService: SuggestionService

    init(suggestionService: SuggestionService? = nil) {
        self.suggestionService = suggestionService ?? Self.defaultService()
    }

    private static func defaultService() -> SuggestionService {
        if BackendConfig.isBackendAvailable {
            return NetworkSuggestionService()
        }
        return MockSuggestionService()
    }

    // MARK: - Coordinate helpers

    /// Convert a world point to screen space using current transform.
    func worldToScreen(_ point: CGPoint) -> CGPoint {
        canvasTransform.worldToScreen(point)
    }

    /// Convert a screen point to world space using current transform.
    func screenToWorld(_ point: CGPoint) -> CGPoint {
        canvasTransform.screenToWorld(point)
    }

    /// Default insertion point for new objects: uses suggestion anchor
    /// if available, offset by transform, otherwise visible center.
    var defaultInsertionPoint: CGPointCodable {
        if let anchor = suggestionAnchor {
            return CGPointCodable(x: anchor.x + 100, y: anchor.y)
        }
        // Approximate visible center in world coords
        return CGPointCodable(x: 520, y: 360)
    }

    // MARK: - Transform sync (called by PencilKit coordinator)

    func syncTransform(scale: CGFloat, offset: CGSize) {
        canvasTransform = CanvasTransform(scale: scale, offset: offset)
    }

    // MARK: - AI Actions

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
            selectedObjectID: selectedObjectID,
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
            ghostSuggestion = nil
        }
    }

    func dismissSuggestion() {
        withAnimation(.easeOut(duration: 0.3)) {
            ghostSuggestion = nil
        }
    }

    // MARK: - Object Actions

    func selectObject(_ id: UUID?) {
        selectedObjectID = id
    }

    func moveObject(id: UUID, to position: CGPointCodable) {
        guard let index = canvasObjects.firstIndex(where: { $0.id == id }) else { return }
        canvasObjects[index].worldPosition = position
    }

    func deleteSelected() {
        guard let id = selectedObjectID else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            canvasObjects.removeAll { $0.id == id }
            selectedObjectID = nil
        }
    }

    func duplicateSelected() {
        guard let id = selectedObjectID,
              let source = canvasObjects.first(where: { $0.id == id }) else { return }
        var copy = source
        copy.id = UUID()
        copy.worldPosition = CGPointCodable(
            x: source.worldPosition.x + 30,
            y: source.worldPosition.y + 30
        )
        copy.source = .user
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            canvasObjects.append(copy)
            selectedObjectID = copy.id
        }
    }

    func addObject(_ object: CanvasObject) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            canvasObjects.append(object)
            selectedObjectID = object.id
        }
    }

    // MARK: - Canvas Actions

    func clearCanvas() {
        drawing = PKDrawing()
    }
}

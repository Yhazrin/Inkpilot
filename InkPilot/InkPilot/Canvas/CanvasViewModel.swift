import SwiftUI
import PencilKit

/// The main state container for the canvas screen.
@Observable
final class CanvasViewModel {

    // MARK: - Drawing State

    var drawing = PKDrawing()
    var selectedTool: CanvasTool = .pen

    // MARK: - Canvas Objects

    var canvasObjects: [CanvasObject] = []
    var selectedObjectID: UUID?

    // MARK: - AI Suggestion State

    var ghostSuggestion: GhostSuggestion?

    // MARK: - AI Panel State

    var isAIPanelExpanded: Bool = false

    // MARK: - Secondary Palette State

    var isShapePaletteVisible: Bool = false
    var isMediaPaletteVisible: Bool = false

    // MARK: - Prompt

    var promptText: String = ""

    // MARK: - Dependencies

    private let suggestionService: SuggestionService

    init(suggestionService: SuggestionService = MockSuggestionService()) {
        self.suggestionService = suggestionService
    }

    // MARK: - AI Actions

    func requestSuggestion() {
        let context = CanvasContextBuilder.build(from: drawing)
        Task { @MainActor in
            do {
                let response = try await suggestionService.generateSuggestion(context: context)
                withAnimation(.easeInOut(duration: 0.4)) {
                    ghostSuggestion = GhostSuggestion(response: response)
                }
            } catch { }
        }
    }

    func acceptSuggestion() {
        guard let suggestion = ghostSuggestion else { return }
        let baseX: CGFloat = 400
        let baseY: CGFloat = 300
        let spacing: CGFloat = 140

        let newObjects = suggestion.response.items.enumerated().map { index, item in
            CanvasObjectFactory.aiCard(
                from: item,
                position: CGPointCodable(x: baseX, y: baseY + CGFloat(index) * spacing)
            )
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            canvasObjects.append(contentsOf: newObjects)
            dismissSuggestion()
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

    // MARK: - Object Creation (from palettes)

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

import SwiftUI
import PencilKit

/// The main state container for the canvas screen.
/// State declarations, init, and coordinate helpers only.
/// AI actions: CanvasViewModel+AI.swift
/// Object operations: CanvasViewModel+ObjectOperations.swift
/// History/selection/alignment/persistence: CanvasViewModel+Actions.swift
@Observable
final class CanvasViewModel {

    // MARK: - Drawing State

    var drawing = PKDrawing()
    var selectedTool: CanvasTool = .pen

    // MARK: - Viewport / Transform

    var canvasTransform: CanvasTransform = .identity

    // MARK: - Canvas Objects

    var canvasObjects: [CanvasObject] = []

    // MARK: - Selection State

    let selection = CanvasSelectionState()

    // MARK: - Smart Guides

    var activeGuides: [GuideLine] = []

    // MARK: - Selection Mode

    var useLasso: Bool = false
    var lassoPoints: [CGPoint] = []

    // MARK: - AI Suggestion State

    var ghostSuggestion: GhostSuggestion?
    var isThinking: Bool = false
    var suggestionAnchor: CGPointCodable?

    // MARK: - AI Panel State

    var isAIPanelExpanded: Bool = false

    // MARK: - Connector Creation State

    var connectorStartID: UUID?

    // MARK: - Secondary Palette State

    var isShapePaletteVisible: Bool = false
    var isMediaPaletteVisible: Bool = false

    // MARK: - Prompt

    var promptText: String = ""

    // MARK: - Drawing Tool State

    let drawingToolState = DrawingToolState()

    // MARK: - History (Undo/Redo)

    let history = CanvasHistoryManager()

    // MARK: - Persistence

    let documentStore = CanvasDocumentStore()

    // MARK: - Dependencies

    let suggestionService: SuggestionService

    init(suggestionService: SuggestionService? = nil) {
        self.suggestionService = suggestionService ?? Self.defaultService()
        restoreCanvas()
    }

    private static func defaultService() -> SuggestionService {
        if BackendConfig.isCustomBackendConfigured {
            return NetworkSuggestionService()
        }
        return MockSuggestionService()
    }

    // MARK: - Coordinate helpers

    func worldToScreen(_ point: CGPoint) -> CGPoint {
        canvasTransform.worldToScreen(point)
    }

    func screenToWorld(_ point: CGPoint) -> CGPoint {
        canvasTransform.screenToWorld(point)
    }

    var defaultInsertionPoint: CGPointCodable {
        if let anchor = suggestionAnchor {
            return CGPointCodable(x: anchor.x + 100, y: anchor.y)
        }
        return Brand.defaultInsertionPoint
    }

    // MARK: - Transform sync

    func syncTransform(scale: CGFloat, offset: CGSize) {
        canvasTransform = CanvasTransform(scale: scale, offset: offset)
    }
}

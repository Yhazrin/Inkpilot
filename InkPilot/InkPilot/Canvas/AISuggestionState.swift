import Foundation

/// Encapsulates AI suggestion state extracted from CanvasViewModel
/// to reduce god-object responsibilities.
@Observable
final class AISuggestionState {
    /// The current ghost suggestion awaiting user action.
    var ghostSuggestion: GhostSuggestion?
    /// Whether the AI is currently processing a request.
    var isThinking: Bool = false
    /// The canvas-space anchor point for the suggestion origin.
    var suggestionAnchor: CGPointCodable?
    /// Whether the AI pilot panel is expanded.
    var isAIPanelExpanded: Bool = false
    /// The user's prompt text.
    var promptText: String = ""
}

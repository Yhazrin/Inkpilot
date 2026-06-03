import Foundation

/// UI state for a pending AI ghost suggestion overlay.
struct GhostSuggestion: Identifiable {
    let id = UUID()
    let response: AISuggestionResponse
}

/// A card that was accepted from an AI suggestion and placed on the canvas.
struct AcceptedCard: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

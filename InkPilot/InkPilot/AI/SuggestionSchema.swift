import Foundation

/// The structured response from an AI suggestion service.
struct AISuggestionResponse: Codable, Equatable {
    let mode: SuggestionMode
    let title: String
    let items: [AISuggestionItem]
}

/// The type of suggestion the AI is providing.
enum SuggestionMode: String, Codable {
    case completion
    case structure
    case component
    case diagram
}

/// A single item within an AI suggestion.
struct AISuggestionItem: Codable, Identifiable, Equatable {
    let id: UUID
    let type: CanvasObjectType
    let title: String
    let content: String
}

/// Lightweight type hint for AI suggestion items.
/// CanvasObjectFactory maps these to full CanvasObjectContent.
enum CanvasObjectType: String, Codable {
    case aiCard
    case textBox
    case stickyNote
    case bubble
    case shape
    case connector
    case image
    case file
    case handwrittenText
}

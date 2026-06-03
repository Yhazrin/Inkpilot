import Foundation

/// The structured response from an AI suggestion service.
struct AISuggestionResponse: Codable {
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
struct AISuggestionItem: Codable, Identifiable {
    let id: UUID
    let type: CanvasObjectType
    let title: String
    let content: String
}

/// Types of objects that can exist on the canvas.
enum CanvasObjectType: String, Codable {
    case ink
    case textCard
    case checklist
    case mindNode
    case diagram
    case ghostSuggestion
}

/// Who created a canvas object.
enum CreatorType: String, Codable {
    case user
    case ai
    case collaborator
}

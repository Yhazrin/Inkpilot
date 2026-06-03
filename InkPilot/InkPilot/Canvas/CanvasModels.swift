import Foundation

// MARK: - Codable Geometry Wrappers

/// Codable wrapper for CGPoint.
struct CGPointCodable: Codable, Equatable {
    var x: CGFloat
    var y: CGFloat

    static let zero = CGPointCodable(x: 0, y: 0)

    var cgPoint: CGPoint { CGPoint(x: x, y: y) }
}

/// Codable wrapper for CGSize.
struct CGSizeCodable: Codable, Equatable {
    var width: CGFloat
    var height: CGFloat

    static let defaultCard = CGSizeCodable(width: 260, height: 120)

    var cgSize: CGSize { CGSize(width: width, height: height) }
}

// MARK: - Canvas Object State

/// UI state for a pending AI ghost suggestion overlay.
struct GhostSuggestion: Identifiable {
    let id = UUID()
    let response: AISuggestionResponse
}

/// A card that was accepted from an AI suggestion and placed on the canvas.
struct AcceptedCard: Identifiable, Codable {
    let id: UUID
    var title: String
    var body: String
    var worldPosition: CGPointCodable
    var size: CGSizeCodable
    var createdBy: CreatorType
}

import Foundation

// MARK: - Codable Geometry Wrappers

struct CGPointCodable: Codable, Equatable {
    var x: CGFloat
    var y: CGFloat
    static let zero = CGPointCodable(x: 0, y: 0)
    var cgPoint: CGPoint { CGPoint(x: x, y: y) }
}

struct CGSizeCodable: Codable, Equatable {
    var width: CGFloat
    var height: CGFloat
    static let defaultCard = CGSizeCodable(width: 260, height: 120)
    static let defaultTextBox = CGSizeCodable(width: 200, height: 80)
    static let defaultSticky = CGSizeCodable(width: 180, height: 180)
    static let defaultBubble = CGSizeCodable(width: 160, height: 160)
    static let defaultShape = CGSizeCodable(width: 140, height: 140)
    static let defaultPlaceholder = CGSizeCodable(width: 200, height: 140)
    var cgSize: CGSize { CGSize(width: width, height: height) }
}

// MARK: - Canvas Object Model

/// The unified model for all objects on the canvas.
struct CanvasObject: Identifiable, Codable {
    let id: UUID
    var type: CanvasObjectType
    var title: String
    var body: String
    var worldPosition: CGPointCodable
    var size: CGSizeCodable
    var source: CanvasObjectSource
    var style: CanvasObjectStyle
    var shapeKind: CanvasShapeKind?
}

/// Types of canvas objects.
enum CanvasObjectType: String, Codable {
    case aiCard
    case textBox
    case stickyNote
    case bubble
    case shape
    case connector
    case image
    case file
}

/// Shape subtypes.
enum CanvasShapeKind: String, Codable {
    case rectangle
    case roundedRectangle
    case ellipse
    case diamond
    case arrow
    case line
}

/// Who or what created the object.
enum CanvasObjectSource: String, Codable {
    case user
    case ai
    case collaborator
}

/// Visual style hints for canvas objects.
struct CanvasObjectStyle: Codable, Equatable {
    var tint: String?
    var isBold: Bool?

    static let `default` = CanvasObjectStyle(tint: nil, isBold: nil)
    static let aiDefault = CanvasObjectStyle(tint: "aiBlue", isBold: nil)
    static let stickyYellow = CanvasObjectStyle(tint: "stickyYellow", isBold: nil)
    static let stickyPink = CanvasObjectStyle(tint: "stickyPink", isBold: nil)
    static let stickyGreen = CanvasObjectStyle(tint: "stickyGreen", isBold: nil)
}

// MARK: - Ghost Suggestion (UI overlay state)

struct GhostSuggestion: Identifiable {
    let id = UUID()
    let response: AISuggestionResponse
}

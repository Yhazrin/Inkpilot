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

// MARK: - Canvas Object Content

/// Typed content for canvas objects, replacing flat title/body.
enum CanvasObjectContent: Codable, Equatable {
    case aiCard(title: String, body: String)
    case text(editableText: String)
    case stickyNote(noteText: String)
    case bubble(bubbleText: String)
    case shape(kind: CanvasShapeKind)
    case connector(startID: UUID?, endID: UUID?)
    case mindNode(label: String, parentID: UUID?)
    case media(assetID: String?, mediaKind: MediaKind)
}

enum MediaKind: String, Codable {
    case image
    case file
}

// MARK: - Canvas Object Model

/// The unified model for all objects on the canvas.
struct CanvasObject: Identifiable, Codable {
    var id: UUID
    var content: CanvasObjectContent
    var worldPosition: CGPointCodable
    var size: CGSizeCodable
    var rotation: CGFloat
    var zIndex: Int
    var groupID: UUID?
    var source: CanvasObjectSource
    var style: CanvasObjectStyle
    var createdAt: Date
    var updatedAt: Date
}

/// Who or what created the object.
enum CanvasObjectSource: String, Codable {
    case user
    case ai
    case collaborator
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

struct GhostSuggestion: Identifiable, Equatable {
    let id = UUID()
    let response: AISuggestionResponse

    static func == (lhs: GhostSuggestion, rhs: GhostSuggestion) -> Bool {
        lhs.id == rhs.id
    }
}

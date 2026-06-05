import Foundation

/// Factory methods for creating canvas objects with sensible defaults.
enum CanvasObjectFactory {

    private static func makeObject(
        content: CanvasObjectContent,
        position: CGPointCodable,
        size: CGSizeCodable,
        source: CanvasObjectSource = .user,
        style: CanvasObjectStyle = .default
    ) -> CanvasObject {
        let now = Date()
        return CanvasObject(
            id: UUID(),
            content: content,
            worldPosition: position,
            size: size,
            rotation: 0,
            zIndex: 0,
            groupID: nil,
            source: source,
            style: style,
            createdAt: now,
            updatedAt: now
        )
    }

    static func aiCard(from item: AISuggestionItem, position: CGPointCodable) -> CanvasObject {
        makeObject(
            content: .aiCard(title: item.title, body: item.content),
            position: position,
            size: CGSizeCodable.defaultCard,
            source: .ai,
            style: .aiDefault
        )
    }

    static func textBox(title: String = "", body: String = "", at position: CGPointCodable = .zero) -> CanvasObject {
        let combined = combineText(title: title, body: body)
        return makeObject(
            content: .text(editableText: combined),
            position: position,
            size: CGSizeCodable.defaultTextBox
        )
    }

    static func stickyNote(title: String = "", body: String = "", at position: CGPointCodable = .zero) -> CanvasObject {
        let combined = combineText(title: title, body: body)
        return makeObject(
            content: .stickyNote(noteText: combined),
            position: position,
            size: CGSizeCodable.defaultSticky,
            style: .stickyYellow
        )
    }

    static func bubble(title: String = "", body: String = "", at position: CGPointCodable = .zero) -> CanvasObject {
        let combined = combineText(title: title, body: body)
        return makeObject(
            content: .bubble(bubbleText: combined),
            position: position,
            size: CGSizeCodable.defaultBubble
        )
    }

    /// Joins `title` and `body` for single-field text content. Drops empty
    /// sides. Title gets a line break before the body so a caller's two
    /// arguments render as two visible lines.
    private static func combineText(title: String, body: String) -> String {
        switch (title.isEmpty, body.isEmpty) {
        case (true, true):   return ""
        case (false, true):  return title
        case (true, false):  return body
        case (false, false): return "\(title)\n\(body)"
        }
    }

    static func shape(kind: CanvasShapeKind, at position: CGPointCodable = .zero) -> CanvasObject {
        makeObject(
            content: .shape(kind: kind),
            position: position,
            size: CGSizeCodable.defaultShape
        )
    }

    static func connector(startID: UUID? = nil, endID: UUID? = nil, at position: CGPointCodable = .zero) -> CanvasObject {
        makeObject(
            content: .connector(startID: startID, endID: endID),
            position: position,
            size: CGSizeCodable(width: 200, height: 4)
        )
    }

    static func mindNode(label: String = "", parentID: UUID? = nil, at position: CGPointCodable = .zero) -> CanvasObject {
        makeObject(
            content: .mindNode(label: label, parentID: parentID),
            position: position,
            size: CGSizeCodable(width: 160, height: 60),
            style: .aiDefault
        )
    }

    static func imagePlaceholder(at position: CGPointCodable = .zero) -> CanvasObject {
        makeObject(
            content: .media(assetID: nil, mediaKind: .image),
            position: position,
            size: CGSizeCodable.defaultPlaceholder
        )
    }

    static func filePlaceholder(at position: CGPointCodable = .zero) -> CanvasObject {
        makeObject(
            content: .media(assetID: nil, mediaKind: .file),
            position: position,
            size: CGSizeCodable.defaultPlaceholder
        )
    }
}

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
        makeObject(
            content: .text(editableText: body.isEmpty ? title : body),
            position: position,
            size: CGSizeCodable.defaultTextBox
        )
    }

    static func stickyNote(title: String = "", body: String = "", at position: CGPointCodable = .zero) -> CanvasObject {
        makeObject(
            content: .stickyNote(noteText: body.isEmpty ? title : body),
            position: position,
            size: CGSizeCodable.defaultSticky,
            style: .stickyYellow
        )
    }

    static func bubble(title: String = "", body: String = "", at position: CGPointCodable = .zero) -> CanvasObject {
        makeObject(
            content: .bubble(bubbleText: body.isEmpty ? title : body),
            position: position,
            size: CGSizeCodable.defaultBubble
        )
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

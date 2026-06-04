import Foundation

/// Factory methods for creating canvas objects with sensible defaults.
enum CanvasObjectFactory {

    static func aiCard(from item: AISuggestionItem, position: CGPointCodable) -> CanvasObject {
        CanvasObject(
            id: item.id,
            type: .aiCard,
            title: item.title,
            body: item.content,
            worldPosition: position,
            size: CGSizeCodable.defaultCard,
            source: .ai,
            style: .aiDefault,
            shapeKind: nil
        )
    }

    static func textBox(title: String = "", body: String = "", at position: CGPointCodable = .zero) -> CanvasObject {
        CanvasObject(
            id: UUID(), type: .textBox, title: title, body: body,
            worldPosition: position, size: CGSizeCodable.defaultTextBox,
            source: .user, style: .default, shapeKind: nil
        )
    }

    static func stickyNote(title: String = "", body: String = "", at position: CGPointCodable = .zero) -> CanvasObject {
        CanvasObject(
            id: UUID(), type: .stickyNote, title: title, body: body,
            worldPosition: position, size: CGSizeCodable.defaultSticky,
            source: .user, style: .stickyYellow, shapeKind: nil
        )
    }

    static func bubble(title: String = "", body: String = "", at position: CGPointCodable = .zero) -> CanvasObject {
        CanvasObject(
            id: UUID(), type: .bubble, title: title, body: body,
            worldPosition: position, size: CGSizeCodable.defaultBubble,
            source: .user, style: .default, shapeKind: nil
        )
    }

    static func shape(kind: CanvasShapeKind, at position: CGPointCodable = .zero) -> CanvasObject {
        CanvasObject(
            id: UUID(), type: .shape, title: "", body: "",
            worldPosition: position, size: CGSizeCodable.defaultShape,
            source: .user, style: .default, shapeKind: kind
        )
    }

    static func connector(at position: CGPointCodable = .zero) -> CanvasObject {
        CanvasObject(
            id: UUID(), type: .connector, title: "", body: "",
            worldPosition: position, size: CGSizeCodable(width: 200, height: 4),
            source: .user, style: .default, shapeKind: nil
        )
    }

    static func imagePlaceholder(at position: CGPointCodable = .zero) -> CanvasObject {
        CanvasObject(
            id: UUID(), type: .image, title: String(localized: "object.image.placeholder"),
            body: "", worldPosition: position, size: CGSizeCodable.defaultPlaceholder,
            source: .user, style: .default, shapeKind: nil
        )
    }

    static func filePlaceholder(at position: CGPointCodable = .zero) -> CanvasObject {
        CanvasObject(
            id: UUID(), type: .file, title: String(localized: "object.file.placeholder"),
            body: "", worldPosition: position, size: CGSizeCodable.defaultPlaceholder,
            source: .user, style: .default, shapeKind: nil
        )
    }
}

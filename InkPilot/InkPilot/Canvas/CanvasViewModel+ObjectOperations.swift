import SwiftUI

/// Object mutation operations for CanvasViewModel.
extension CanvasViewModel {

    func updateObjectText(id: UUID, newText: String) {
        guard let index = canvasObjects.firstIndex(where: { $0.id == id }) else { return }
        switch canvasObjects[index].content {
        case .aiCard(let title, _):
            canvasObjects[index].content = .aiCard(title: title, body: newText)
        case .text:
            canvasObjects[index].content = .text(editableText: newText)
        case .stickyNote:
            canvasObjects[index].content = .stickyNote(noteText: newText)
        case .bubble:
            canvasObjects[index].content = .bubble(bubbleText: newText)
        default: break
        }
        canvasObjects[index].updatedAt = Date()
    }

    func moveObject(id: UUID, to position: CGPointCodable) {
        guard let index = canvasObjects.firstIndex(where: { $0.id == id }) else { return }
        canvasObjects[index].worldPosition = position
        canvasObjects[index].updatedAt = Date()
    }

    func moveObjectWithGuides(id: UUID, to proposedPosition: CGPointCodable) {
        guard let obj = canvasObjects.first(where: { $0.id == id }) else { return }
        let result = SmartGuideEngine.compute(
            draggedObject: obj, proposedPosition: proposedPosition, otherObjects: canvasObjects
        )
        activeGuides = result.guides
        moveObject(id: id, to: result.position)
    }

    func clearGuides() { activeGuides = [] }

    func moveSelectedObjects(by delta: CGPointCodable) {
        for id in selection.selectedIDs {
            guard let index = canvasObjects.firstIndex(where: { $0.id == id }) else { continue }
            canvasObjects[index].worldPosition = CGPointCodable(
                x: canvasObjects[index].worldPosition.x + delta.x,
                y: canvasObjects[index].worldPosition.y + delta.y
            )
            canvasObjects[index].updatedAt = Date()
        }
    }

    func pushHistoryBeforeMove() {
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
    }

    func resizeObject(id: UUID, to newSize: CGSizeCodable) {
        guard let index = canvasObjects.firstIndex(where: { $0.id == id }) else { return }
        canvasObjects[index].size = newSize
        canvasObjects[index].updatedAt = Date()
    }

    func pushHistoryBeforeResize() {
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
    }

    func deleteSelected() {
        guard selection.hasSelection else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        withAnimation(MotionTokens.quickFadeOut) {
            canvasObjects.removeAll { selection.isSelected($0.id) }
            selection.clearSelection()
        }
        autoSave()
    }

    func duplicateSelected() {
        guard selection.hasSelection else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        let sources = canvasObjects.filter { selection.isSelected($0.id) }
        let offset = Brand.duplicateOffset
        var newIDs: Set<UUID> = []
        withAnimation(MotionTokens.objectAdd) {
            for (i, source) in sources.enumerated() {
                var copy = source
                copy.id = UUID()
                copy.worldPosition = CGPointCodable(
                    x: source.worldPosition.x + offset + CGFloat(i) * Brand.duplicateStagger,
                    y: source.worldPosition.y + offset + CGFloat(i) * Brand.duplicateStagger
                )
                copy.source = .user
                canvasObjects.append(copy)
                newIDs.insert(copy.id)
            }
            selection.selectObjects(newIDs)
        }
        autoSave()
    }

    func addObject(_ object: CanvasObject) {
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        withAnimation(MotionTokens.objectAdd) {
            canvasObjects.append(object)
            selection.selectObject(object.id)
        }
        autoSave()
    }

    func handleConnectorTap(_ objectID: UUID) {
        if let startID = connectorStartID {
            let startObj = canvasObjects.first(where: { $0.id == startID })
            let endObj = canvasObjects.first(where: { $0.id == objectID })
            if let startObj, let endObj {
                let midX = (startObj.worldPosition.x + endObj.worldPosition.x) / 2
                let midY = (startObj.worldPosition.y + endObj.worldPosition.y) / 2
                var connector = CanvasObjectFactory.connector(
                    startID: startID, endID: objectID,
                    at: CGPointCodable(x: midX, y: midY)
                )
                let dx = abs(endObj.worldPosition.x - startObj.worldPosition.x)
                let dy = abs(endObj.worldPosition.y - startObj.worldPosition.y)
                connector.size = CGSizeCodable(width: max(dx, Brand.touchTarget), height: max(dy, Brand.spacingXS))
                addObject(connector)
            }
            connectorStartID = nil
        } else {
            connectorStartID = objectID
        }
    }
}

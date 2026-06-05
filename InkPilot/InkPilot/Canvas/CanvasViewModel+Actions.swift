import SwiftUI
import PencilKit

/// Undo/redo, selection ordering, alignment, grouping, and persistence.
extension CanvasViewModel {

    // MARK: - Lasso Selection

    func selectObjectsInLasso(_ screenPoints: [CGPoint]) {
        guard screenPoints.count >= 3 else { return }
        let worldPoints = screenPoints.map { canvasTransform.screenToWorld($0) }
        let ids = canvasObjects.filter { obj in
            let center = CGPoint(
                x: obj.worldPosition.x + obj.size.width / 2,
                y: obj.worldPosition.y + obj.size.height / 2
            )
            return isPointInsidePolygon(center, polygon: worldPoints)
        }.map(\.id)
        if !ids.isEmpty {
            selection.selectObjects(Set(ids))
        }
    }

    // MARK: - Undo / Redo

    func undo() {
        guard let snapshot = history.undo(currentDrawing: drawing, currentObjects: canvasObjects) else { return }
        drawing = snapshot.drawing
        canvasObjects = snapshot.canvasObjects
        selection.clearSelection()
        autoSave()
    }

    func redo() {
        guard let snapshot = history.redo(currentDrawing: drawing, currentObjects: canvasObjects) else { return }
        drawing = snapshot.drawing
        canvasObjects = snapshot.canvasObjects
        selection.clearSelection()
        autoSave()
    }

    // MARK: - Layer Ordering

    func bringForward() {
        guard selection.hasSelection else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        for id in selection.selectedIDs {
            guard let i = canvasObjects.firstIndex(where: { $0.id == id }) else { continue }
            canvasObjects[i].zIndex += 1
        }
        autoSave()
    }

    func sendBackward() {
        guard selection.hasSelection else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        for id in selection.selectedIDs {
            guard let i = canvasObjects.firstIndex(where: { $0.id == id }) else { continue }
            canvasObjects[i].zIndex = max(0, canvasObjects[i].zIndex - 1)
        }
        autoSave()
    }

    func bringToFront() {
        guard selection.hasSelection else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        let maxZ = canvasObjects.map(\.zIndex).max() ?? 0
        for (offset, id) in selection.selectedIDs.enumerated() {
            guard let i = canvasObjects.firstIndex(where: { $0.id == id }) else { continue }
            canvasObjects[i].zIndex = maxZ + 1 + offset
        }
        autoSave()
    }

    func sendToBack() {
        guard selection.hasSelection else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        for (offset, id) in selection.selectedIDs.enumerated() {
            guard let i = canvasObjects.firstIndex(where: { $0.id == id }) else { continue }
            canvasObjects[i].zIndex = offset
        }
        autoSave()
    }

    // MARK: - Alignment

    func alignLeft() {
        let selected = selectedObjects()
        guard selected.count >= 2,
              let minX = selected.map(\.worldPosition.x).min() else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        for obj in selected {
            guard let i = canvasObjects.firstIndex(where: { $0.id == obj.id }) else { continue }
            canvasObjects[i].worldPosition.x = minX
        }
        autoSave()
    }

    func alignCenterH() {
        let selected = selectedObjects()
        guard selected.count >= 2 else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        let avgX = selected.map(\.worldPosition.x).reduce(0, +) / CGFloat(selected.count)
        for obj in selected {
            guard let i = canvasObjects.firstIndex(where: { $0.id == obj.id }) else { continue }
            canvasObjects[i].worldPosition.x = avgX
        }
        autoSave()
    }

    func alignRight() {
        let selected = selectedObjects()
        guard selected.count >= 2,
              let maxX = selected.map({ $0.worldPosition.x + $0.size.width }).max() else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        for obj in selected {
            guard let i = canvasObjects.firstIndex(where: { $0.id == obj.id }) else { continue }
            canvasObjects[i].worldPosition.x = maxX - obj.size.width
        }
        autoSave()
    }

    func alignTop() {
        let selected = selectedObjects()
        guard selected.count >= 2,
              let minY = selected.map(\.worldPosition.y).min() else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        for obj in selected {
            guard let i = canvasObjects.firstIndex(where: { $0.id == obj.id }) else { continue }
            canvasObjects[i].worldPosition.y = minY
        }
        autoSave()
    }

    func alignMiddleV() {
        let selected = selectedObjects()
        guard selected.count >= 2 else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        let avgY = selected.map(\.worldPosition.y).reduce(0, +) / CGFloat(selected.count)
        for obj in selected {
            guard let i = canvasObjects.firstIndex(where: { $0.id == obj.id }) else { continue }
            canvasObjects[i].worldPosition.y = avgY
        }
        autoSave()
    }

    func alignBottom() {
        let selected = selectedObjects()
        guard selected.count >= 2,
              let maxY = selected.map({ $0.worldPosition.y + $0.size.height }).max() else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        for obj in selected {
            guard let i = canvasObjects.firstIndex(where: { $0.id == obj.id }) else { continue }
            canvasObjects[i].worldPosition.y = maxY - obj.size.height
        }
        autoSave()
    }

    func distributeHorizontal() {
        let selected = selectedObjects().sorted { $0.worldPosition.x < $1.worldPosition.x }
        guard selected.count >= 3,
              let first = selected.first,
              let last = selected.last else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        let minX = first.worldPosition.x
        let maxX = last.worldPosition.x + last.size.width
        let totalWidth = selected.reduce(0) { $0 + $1.size.width }
        let spacing = (maxX - minX - totalWidth) / CGFloat(selected.count - 1)
        var x = minX
        for obj in selected {
            guard let i = canvasObjects.firstIndex(where: { $0.id == obj.id }) else { continue }
            canvasObjects[i].worldPosition.x = x
            x += obj.size.width + spacing
        }
        autoSave()
    }

    func distributeVertical() {
        let selected = selectedObjects().sorted { $0.worldPosition.y < $1.worldPosition.y }
        guard selected.count >= 3,
              let first = selected.first,
              let last = selected.last else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        let minY = first.worldPosition.y
        let maxY = last.worldPosition.y + last.size.height
        let totalHeight = selected.reduce(0) { $0 + $1.size.height }
        let spacing = (maxY - minY - totalHeight) / CGFloat(selected.count - 1)
        var y = minY
        for obj in selected {
            guard let i = canvasObjects.firstIndex(where: { $0.id == obj.id }) else { continue }
            canvasObjects[i].worldPosition.y = y
            y += obj.size.height + spacing
        }
        autoSave()
    }

    // MARK: - Grouping

    func groupSelected() {
        guard selection.selectionCount >= 2 else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        let groupID = UUID()
        for id in selection.selectedIDs {
            guard let i = canvasObjects.firstIndex(where: { $0.id == id }) else { continue }
            canvasObjects[i].groupID = groupID
        }
        autoSave()
    }

    func ungroupSelected() {
        guard selection.hasSelection else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        for id in selection.selectedIDs {
            guard let i = canvasObjects.firstIndex(where: { $0.id == id }) else { continue }
            canvasObjects[i].groupID = nil
        }
        autoSave()
    }

    // MARK: - Canvas Clear

    func clearCanvas() {
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        drawing = PKDrawing()
        canvasObjects.removeAll()
        selection.clearSelection()
        activeGuides = []
        connectorStartID = nil
        lassoPoints = []
        ghostSuggestion = nil
        suggestionAnchor = nil
        autoSave()
    }

    // MARK: - Persistence

    func restoreCanvas() {
        guard let doc = documentStore.load() else { return }
        drawing = doc.drawing
        canvasObjects = doc.canvasObjects
    }

    func autoSave() {
        documentStore.saveDebounced(drawing: drawing, objects: canvasObjects)
    }

    // MARK: - Select All

    func selectAllObjects() {
        let allIDs = Set(canvasObjects.map(\.id))
        selection.selectObjects(allIDs)
    }

    // MARK: - Helpers

    private func selectedObjects() -> [CanvasObject] {
        canvasObjects.filter { selection.isSelected($0.id) }
    }
}

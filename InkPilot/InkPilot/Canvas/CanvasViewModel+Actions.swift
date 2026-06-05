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
            return center.isInsidePolygon(worldPoints)
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
        alignPositions(minCount: 2) { objs in
            guard let minX = objs.map(\.worldPosition.x).min() else { return nil }
            return { CGPointCodable(x: minX, y: $0.worldPosition.y) }
        }
    }

    func alignCenterH() {
        alignPositions(minCount: 2) { objs in
            let avgX = objs.map(\.worldPosition.x).reduce(0, +) / CGFloat(objs.count)
            return { CGPointCodable(x: avgX, y: $0.worldPosition.y) }
        }
    }

    func alignRight() {
        alignPositions(minCount: 2) { objs in
            guard let maxX = objs.map({ $0.worldPosition.x + $0.size.width }).max() else { return nil }
            return { CGPointCodable(x: maxX - $0.size.width, y: $0.worldPosition.y) }
        }
    }

    func alignTop() {
        alignPositions(minCount: 2) { objs in
            guard let minY = objs.map(\.worldPosition.y).min() else { return nil }
            return { CGPointCodable(x: $0.worldPosition.x, y: minY) }
        }
    }

    func alignMiddleV() {
        alignPositions(minCount: 2) { objs in
            let avgY = objs.map(\.worldPosition.y).reduce(0, +) / CGFloat(objs.count)
            return { CGPointCodable(x: $0.worldPosition.x, y: avgY) }
        }
    }

    func alignBottom() {
        alignPositions(minCount: 2) { objs in
            guard let maxY = objs.map({ $0.worldPosition.y + $0.size.height }).max() else { return nil }
            return { CGPointCodable(x: $0.worldPosition.x, y: maxY - $0.size.height) }
        }
    }

    func distributeHorizontal() {
        distributePositions(
            pos: \.x, size: \.width,
            setter: { obj, val in CGPointCodable(x: val, y: obj.worldPosition.y) }
        )
    }

    func distributeVertical() {
        distributePositions(
            pos: \.y, size: \.height,
            setter: { obj, val in CGPointCodable(x: obj.worldPosition.x, y: val) }
        )
    }

    /// Generic alignment: computes a target position for each selected object and applies it.
    private func alignPositions(
        minCount: Int,
        compute: ([CanvasObject]) -> ((CanvasObject) -> CGPointCodable)?
    ) {
        let selected = selectedObjects()
        guard selected.count >= minCount,
              let transform = compute(selected) else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        for obj in selected {
            guard let i = canvasObjects.firstIndex(where: { $0.id == obj.id }) else { continue }
            canvasObjects[i].worldPosition = transform(obj)
        }
        autoSave()
    }

    /// Generic distribution: evenly spaces selected objects along an axis.
    private func distributePositions(
        pos: KeyPath<CGPointCodable, CGFloat>,
        size: KeyPath<CGSizeCodable, CGFloat>,
        setter: (CanvasObject, CGFloat) -> CGPointCodable
    ) {
        let selected = selectedObjects().sorted { $0.worldPosition[keyPath: pos] < $1.worldPosition[keyPath: pos] }
        guard selected.count >= 3,
              let first = selected.first,
              let last = selected.last else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        let start = first.worldPosition[keyPath: pos]
        let end = last.worldPosition[keyPath: pos] + last.size[keyPath: size]
        let totalSize = selected.reduce(0) { $0 + $1.size[keyPath: size] }
        let spacing = (end - start - totalSize) / CGFloat(selected.count - 1)
        var p = start
        for obj in selected {
            guard let i = canvasObjects.firstIndex(where: { $0.id == obj.id }) else { continue }
            canvasObjects[i].worldPosition = setter(obj, p)
            p += obj.size[keyPath: size] + spacing
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
        ai.ghostSuggestion = nil
        ai.suggestionAnchor = nil
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

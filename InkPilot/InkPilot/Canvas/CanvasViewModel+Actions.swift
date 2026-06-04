import SwiftUI
import PencilKit

/// Undo/redo, selection ordering, and persistence actions for CanvasViewModel.
extension CanvasViewModel {

    // MARK: - Undo / Redo

    func undo() {
        guard let snapshot = history.undo(currentDrawing: drawing, currentObjects: canvasObjects) else { return }
        drawing = snapshot.drawing
        canvasObjects = snapshot.canvasObjects
        selectedObjectID = nil
        autoSave()
    }

    func redo() {
        guard let snapshot = history.redo(currentDrawing: drawing, currentObjects: canvasObjects) else { return }
        drawing = snapshot.drawing
        canvasObjects = snapshot.canvasObjects
        selectedObjectID = nil
        autoSave()
    }

    // MARK: - Selection Actions (z-index)

    func bringForward() {
        guard let id = selectedObjectID,
              let index = canvasObjects.firstIndex(where: { $0.id == id }) else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        canvasObjects[index].zIndex += 1
        autoSave()
    }

    func sendBackward() {
        guard let id = selectedObjectID,
              let index = canvasObjects.firstIndex(where: { $0.id == id }) else { return }
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        canvasObjects[index].zIndex = max(0, canvasObjects[index].zIndex - 1)
        autoSave()
    }

    // MARK: - Canvas Clear

    func clearCanvas() {
        history.pushSnapshot(drawing: drawing, objects: canvasObjects)
        drawing = PKDrawing()
        canvasObjects.removeAll()
        selectedObjectID = nil
        autoSave()
    }

    // MARK: - Persistence

    func restoreCanvas() {
        guard let doc = documentStore.load() else { return }
        drawing = doc.drawing
        canvasObjects = doc.canvasObjects
    }

    func autoSave() {
        autoSaveTask?.cancel()
        autoSaveTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard let self, !Task.isCancelled else { return }
            self.documentStore.saveDebounced(drawing: self.drawing, objects: self.canvasObjects)
        }
    }
}

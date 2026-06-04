import Foundation
import PencilKit

/// Snapshot of canvas state for undo/redo.
struct CanvasSnapshot {
    let drawing: PKDrawing
    let canvasObjects: [CanvasObject]
}

/// Simple snapshot-based undo/redo manager.
/// Pushes snapshots before major mutations, not every drag frame.
@Observable
final class CanvasHistoryManager {
    private(set) var canUndo: Bool = false
    private(set) var canRedo: Bool = false

    private var undoStack: [CanvasSnapshot] = []
    private var redoStack: [CanvasSnapshot] = []
    private let maxHistory: Int = 30

    /// Push a snapshot before a mutation. Call this BEFORE making changes.
    func pushSnapshot(drawing: PKDrawing, objects: [CanvasObject]) {
        let snapshot = CanvasSnapshot(drawing: drawing, canvasObjects: objects)
        undoStack.append(snapshot)
        if undoStack.count > maxHistory {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
        updateFlags()
    }

    /// Undo: returns the previous snapshot, or nil if nothing to undo.
    func undo(currentDrawing: PKDrawing, currentObjects: [CanvasObject]) -> CanvasSnapshot? {
        guard !undoStack.isEmpty else { return nil }
        // Save current state to redo stack
        let current = CanvasSnapshot(drawing: currentDrawing, canvasObjects: currentObjects)
        redoStack.append(current)
        let previous = undoStack.removeLast()
        updateFlags()
        return previous
    }

    /// Redo: returns the next snapshot, or nil if nothing to redo.
    func redo(currentDrawing: PKDrawing, currentObjects: [CanvasObject]) -> CanvasSnapshot? {
        guard !redoStack.isEmpty else { return nil }
        let current = CanvasSnapshot(drawing: currentDrawing, canvasObjects: currentObjects)
        undoStack.append(current)
        let next = redoStack.removeLast()
        updateFlags()
        return next
    }

    /// Clear all history.
    func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
        updateFlags()
    }

    private func updateFlags() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }
}

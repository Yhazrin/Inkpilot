import XCTest
import PencilKit
@testable import InkPilot

final class CanvasHistoryManagerTests: XCTestCase {

    func testUndoReturnsNilWhenEmpty() {
        let manager = CanvasHistoryManager()
        let result = manager.undo(currentDrawing: PKDrawing(), currentObjects: [])
        XCTAssertNil(result)
        XCTAssertFalse(manager.canUndo)
    }

    func testRedoReturnsNilWhenEmpty() {
        let manager = CanvasHistoryManager()
        let result = manager.redo(currentDrawing: PKDrawing(), currentObjects: [])
        XCTAssertNil(result)
        XCTAssertFalse(manager.canRedo)
    }

    func testPushSnapshotEnablesUndo() {
        let manager = CanvasHistoryManager()
        manager.pushSnapshot(drawing: PKDrawing(), objects: [])
        XCTAssertTrue(manager.canUndo)
        XCTAssertFalse(manager.canRedo)
    }

    func testUndoRestoresPreviousState() {
        let manager = CanvasHistoryManager()
        let obj = CanvasObjectFactory.textBox(title: "Test", at: .zero)

        // Push initial state
        manager.pushSnapshot(drawing: PKDrawing(), objects: [])

        // "Add" an object
        let objectsWithOne = [obj]

        // Undo should restore empty state
        let snapshot = manager.undo(currentDrawing: PKDrawing(), currentObjects: objectsWithOne)
        XCTAssertNotNil(snapshot)
        XCTAssertTrue(snapshot!.canvasObjects.isEmpty)
    }

    func testRedoAfterUndo() {
        let manager = CanvasHistoryManager()
        let obj = CanvasObjectFactory.textBox(title: "Test", at: .zero)

        manager.pushSnapshot(drawing: PKDrawing(), objects: [])
        let _ = manager.undo(currentDrawing: PKDrawing(), currentObjects: [obj])

        XCTAssertTrue(manager.canRedo)

        let redoSnapshot = manager.redo(currentDrawing: PKDrawing(), currentObjects: [])
        XCTAssertNotNil(redoSnapshot)
        XCTAssertEqual(redoSnapshot!.canvasObjects.count, 1)
    }

    func testNewActionClearsRedo() {
        let manager = CanvasHistoryManager()

        manager.pushSnapshot(drawing: PKDrawing(), objects: [])
        let _ = manager.undo(currentDrawing: PKDrawing(), currentObjects: [])
        XCTAssertTrue(manager.canRedo)

        // New action should clear redo
        manager.pushSnapshot(drawing: PKDrawing(), objects: [])
        XCTAssertFalse(manager.canRedo)
    }

    func testMaxHistoryLimit() {
        let manager = CanvasHistoryManager()

        // Push 35 snapshots (max is 30)
        for _ in 0..<35 {
            manager.pushSnapshot(drawing: PKDrawing(), objects: [])
        }

        // Should still be able to undo (capped at 30)
        XCTAssertTrue(manager.canUndo)
    }
}

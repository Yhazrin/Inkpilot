import Foundation
import PencilKit

/// A saveable canvas document.
struct CanvasDocument: Codable {
    let drawingData: Data
    let canvasObjects: [CanvasObject]
    let createdAt: Date
    let updatedAt: Date
    let appVersion: String

    init(drawing: PKDrawing, canvasObjects: [CanvasObject], createdAt: Date = Date()) {
        self.drawingData = drawing.dataRepresentation()
        self.canvasObjects = canvasObjects
        self.createdAt = createdAt
        self.updatedAt = Date()
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    var drawing: PKDrawing {
        (try? PKDrawing(data: drawingData)) ?? PKDrawing()
    }
}

/// Persists canvas state to local disk.
/// Auto-saves with debouncing. Restores on launch.
final class CanvasDocumentStore {
    private let fileName = "inkpilot_canvas.json"
    private var saveTask: Task<Void, Never>?

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent(fileName)
    }

    /// Save the current canvas state. Debounced to avoid excessive writes.
    func saveDebounced(drawing: PKDrawing, objects: [CanvasObject]) {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce
            guard !Task.isCancelled else { return }
            save(drawing: drawing, objects: objects)
        }
    }

    /// Save immediately.
    func save(drawing: PKDrawing, objects: [CanvasObject]) {
        let doc = CanvasDocument(drawing: drawing, canvasObjects: objects)
        guard let data = try? JSONEncoder().encode(doc) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    /// Load the saved canvas, or nil if nothing saved.
    func load() -> CanvasDocument? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(CanvasDocument.self, from: data)
    }

    /// Delete saved canvas.
    func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}

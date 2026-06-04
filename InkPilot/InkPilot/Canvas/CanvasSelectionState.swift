import Foundation

/// Manages multi-selection state for canvas objects.
/// Separate from CanvasViewModel to keep concerns isolated.
@Observable
final class CanvasSelectionState {
    private(set) var selectedIDs: Set<UUID> = []
    var editingID: UUID?

    /// The primary selected ID (last selected, or first in set).
    var primaryID: UUID? {
        editingID ?? selectedIDs.first
    }

    var hasSelection: Bool {
        !selectedIDs.isEmpty
    }

    var selectionCount: Int {
        selectedIDs.count
    }

    var isSingleSelection: Bool {
        selectedIDs.count == 1
    }

    // MARK: - Selection Actions

    func selectObject(_ id: UUID) {
        selectedIDs = [id]
        editingID = nil
    }

    func toggleSelection(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
        editingID = nil
    }

    func selectObjects(_ ids: Set<UUID>) {
        selectedIDs = ids
        editingID = nil
    }

    func clearSelection() {
        selectedIDs.removeAll()
        editingID = nil
    }

    func isSelected(_ id: UUID) -> Bool {
        selectedIDs.contains(id)
    }

    // MARK: - Editing

    func beginEditing(_ id: UUID) {
        selectedIDs = [id]
        editingID = id
    }

    func endEditing() {
        editingID = nil
    }

    // MARK: - Group Selection

    /// Select all objects in the same group.
    func selectGroup(_ groupID: UUID?, allObjects: [CanvasObject]) {
        guard let groupID else { return }
        let groupMembers = allObjects
            .filter { $0.groupID == groupID }
            .map { $0.id }
        selectedIDs = Set(groupMembers)
        editingID = nil
    }
}

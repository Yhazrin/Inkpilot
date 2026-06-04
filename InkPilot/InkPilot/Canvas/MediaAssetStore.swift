import Foundation

/// Represents a media asset referenced by a canvas object.
/// V0.2: metadata only — no real file import yet.
struct MediaAsset: Identifiable, Codable {
    let id: UUID
    var kind: MediaKind
    var fileName: String?
    var localURL: URL?
    var thumbnailData: Data?
    var createdAt: Date

    static func placeholder(kind: MediaKind) -> MediaAsset {
        MediaAsset(
            id: UUID(),
            kind: kind,
            fileName: nil,
            localURL: nil,
            thumbnailData: nil,
            createdAt: Date()
        )
    }
}

/// In-memory store for media assets.
/// V0.2: no persistence, no real file import.
/// V0.3: PhotosPicker / UIDocumentPicker integration.
@Observable
final class MediaAssetStore {
    private var assets: [UUID: MediaAsset] = [:]

    func register(_ asset: MediaAsset) {
        assets[asset.id] = asset
    }

    func get(id: UUID) -> MediaAsset? {
        assets[id]
    }

    func remove(id: UUID) {
        assets.removeValue(forKey: id)
    }
}

import Foundation

/// A user's handwriting profile — the identity of "whose hand" writes on the canvas.
/// One profile per Apple Pencil user; samples are stored under `profile.id`.
// MARK: - Handwriting Profile

struct HandwritingProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date

    /// Style hints that can be derived later from sample statistics.
    /// For V0.1.5 we only store the profile metadata; style inference lives in V0.2.
    var baseFontSize: CGFloat
    var baseSlant: CGFloat
    var pressureMean: CGFloat

    init(
        id: UUID = UUID(),
        name: String,
        baseFontSize: CGFloat = 28,
        baseSlant: CGFloat = 0,
        pressureMean: CGFloat = 0.5
    ) {
        self.id = id
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
        self.baseFontSize = baseFontSize
        self.baseSlant = baseSlant
        self.pressureMean = pressureMean
    }
}

/// A captured stroke sample for a single character, digit, or symbol.
// MARK: - Handwriting Sample

struct HandwritingSample: Identifiable, Codable, Equatable {
    let id: UUID
    /// The character this stroke represents (a single grapheme cluster).
    let character: String
    /// Serialized PKDrawing data — preserves original pressure, azimuth, etc.
    let drawingData: Data
    let capturedAt: Date
    /// Bounding box of the original sample in its source canvas coordinates.
    let sourceBounds: CGRectCodable
}

struct CGRectCodable: Codable, Equatable {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var cgRect: CGRect { CGRect(x: x, y: y, width: width, height: height) }
    init(_ rect: CGRect) {
        self.x = rect.origin.x
        self.y = rect.origin.y
        self.width = rect.width
        self.height = rect.height
    }
}

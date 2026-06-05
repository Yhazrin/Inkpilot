import Foundation
import PencilKit

/// In-memory index of `character -> [HandwritingSample]`.
/// Loaded on demand from `HandwritingSampleStore` for a given profile.
/// Thread-safety: this is an actor-free value type. Read/write only on the
/// main actor (calibration UI + AI accept path both run on main).
struct StrokeGlyphLibrary {
    /// Indexed samples keyed by the character they represent.
    /// Multiple samples per character enable variation in synthesis.
    private(set) var samplesByCharacter: [String: [HandwritingSample]] = [:]

    /// Sample ID -> drawing data cache, populated lazily as samples are
    /// fetched from disk during synthesis.
    private var drawingCache: [UUID: Data] = [:]

    let profileID: UUID

    init(profileID: UUID) {
        self.profileID = profileID
    }

    // MARK: - Population

    /// Load all samples for this profile from disk and index by character.
    @discardableResult
    mutating func loadFromStore() throws -> Int {
        let samples = try HandwritingSampleStore.loadSamples(for: profileID)
        samplesByCharacter = Dictionary(grouping: samples, by: { $0.character })
        return samples.count
    }

    /// Append a new sample to the in-memory index.
    mutating func register(_ sample: HandwritingSample) {
        samplesByCharacter[sample.character, default: []].append(sample)
    }

    // MARK: - Lookup

    /// Returns the available sample IDs for a character, or empty if none.
    func sampleIDs(for character: String) -> [UUID] {
        samplesByCharacter[character]?.map(\.id) ?? []
    }

    func hasCoverage(for character: String) -> Bool {
        !(samplesByCharacter[character]?.isEmpty ?? true)
    }

    /// All characters with at least one sample.
    var coveredCharacters: Set<String> {
        Set(samplesByCharacter.keys)
    }

    /// Coverage stats: total samples, unique characters.
    var stats: (samples: Int, characters: Int) {
        let total = samplesByCharacter.values.reduce(0) { $0 + $1.count }
        return (total, samplesByCharacter.count)
    }

    // MARK: - Drawing Data Access

    /// Resolve drawing data for a sample ID, hitting the cache or disk.
    mutating func drawingData(for sampleID: UUID) -> Data? {
        if let cached = drawingCache[sampleID] { return cached }
        guard let sample = findSample(by: sampleID) else { return nil }
        do {
            let data = try HandwritingSampleStore.loadDrawingData(for: sample, profileID: profileID)
            drawingCache[sampleID] = data
            return data
        } catch {
            return nil
        }
    }

    /// Pre-warm the cache for a set of character strings.
    /// Useful before synthesis so we know upfront which characters are covered.
    mutating func prewarm(forCharacters characters: [String]) {
        for char in characters {
            for id in sampleIDs(for: char) {
                _ = drawingData(for: id)
            }
        }
    }

    private func findSample(by id: UUID) -> HandwritingSample? {
        for samples in samplesByCharacter.values {
            if let match = samples.first(where: { $0.id == id }) {
                return match
            }
        }
        return nil
    }
}

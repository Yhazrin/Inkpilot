import Foundation
import os.log

/// Persists handwriting profiles and their PKStroke samples to disk.
/// Layout:
///   Documents/handwriting/
///     profiles.json           (array of HandwritingProfile)
///     <profile.id>/
///       samples.json          (array of HandwritingSample metadata)
///       <sample.id>.pkdrawing (raw PKDrawing data for each sample)
///
/// We intentionally keep this file-based (no Core Data, no SwiftData) so
/// PKDrawing bytes can be streamed in and out without a serialization tax.
enum HandwritingSampleStore {
    private static let logger = Logger(subsystem: "com.inkpilot.handwriting", category: "SampleStore")
    private static let rootDirName = "handwriting"
    private static let profilesFileName = "profiles.json"
    private static let samplesFileName = "samples.json"

    // MARK: - Paths

    private static var rootURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(rootDirName, isDirectory: true)
    }

    private static func profileDir(_ profileID: UUID) -> URL {
        rootURL.appendingPathComponent(profileID.uuidString, isDirectory: true)
    }

    private static func profilesFile() -> URL {
        rootURL.appendingPathComponent(profilesFileName)
    }

    private static func samplesFile(_ profileID: UUID) -> URL {
        profileDir(profileID).appendingPathComponent(samplesFileName)
    }

    private static func sampleDrawingFile(_ profileID: UUID, sampleID: UUID) -> URL {
        profileDir(profileID).appendingPathComponent("\(sampleID.uuidString).pkdrawing")
    }

    // MARK: - Profile CRUD

    static func createProfile(name: String) throws -> HandwritingProfile {
        let profile = HandwritingProfile(name: name)
        var profiles = try loadProfiles()
        profiles.append(profile)
        try saveProfiles(profiles)
        try FileManager.default.createDirectory(at: profileDir(profile.id), withIntermediateDirectories: true)
        try saveSamples([], for: profile.id)
        logger.info("Created handwriting profile \(profile.id.uuidString, privacy: .public)")
        return profile
    }

    static func loadProfiles() throws -> [HandwritingProfile] {
        let url = profilesFile()
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([HandwritingProfile].self, from: data)
    }

    static func deleteProfile(_ id: UUID) throws {
        var profiles = try loadProfiles()
        profiles.removeAll { $0.id == id }
        try saveProfiles(profiles)
        let dir = profileDir(id)
        if FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.removeItem(at: dir)
        }
    }

    private static func saveProfiles(_ profiles: [HandwritingProfile]) throws {
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(profiles)
        try data.write(to: profilesFile(), options: .atomic)
    }

    // MARK: - Sample CRUD

    static func saveSample(
        character: String,
        drawingData: Data,
        sourceBounds: CGRect,
        profileID: UUID
    ) throws -> HandwritingSample {
        let sample = HandwritingSample(
            id: UUID(),
            character: character,
            drawingData: drawingData,
            capturedAt: Date(),
            sourceBounds: CGRectCodable(sourceBounds)
        )
        try FileManager.default.createDirectory(at: profileDir(profileID), withIntermediateDirectories: true)
        try drawingData.write(to: sampleDrawingFile(profileID, sampleID: sample.id), options: .atomic)

        var samples = try loadSamples(for: profileID)
        samples.append(sample)
        try saveSamples(samples, for: profileID)
        return sample
    }

    static func loadSamples(for profileID: UUID) throws -> [HandwritingSample] {
        let url = samplesFile(profileID)
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([HandwritingSample].self, from: data)
    }

    static func loadDrawingData(for sample: HandwritingSample, profileID: UUID) throws -> Data {
        let url = sampleDrawingFile(profileID, sampleID: sample.id)
        return try Data(contentsOf: url)
    }

    static func deleteSample(_ sampleID: UUID, profileID: UUID) throws {
        var samples = try loadSamples(for: profileID)
        samples.removeAll { $0.id == sampleID }
        try saveSamples(samples, for: profileID)
        let url = sampleDrawingFile(profileID, sampleID: sampleID)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    private static func saveSamples(_ samples: [HandwritingSample], for profileID: UUID) throws {
        try FileManager.default.createDirectory(at: profileDir(profileID), withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(samples)
        try data.write(to: samplesFile(profileID), options: .atomic)
    }

    // MARK: - Active Profile Convenience

    /// Returns the most recently updated profile, or nil if none exists.
    /// Used as the implicit "current" profile for synthesis when the user
    /// hasn't explicitly chosen one.
    static func activeProfile() throws -> HandwritingProfile? {
        let profiles = try loadProfiles()
        return profiles.sorted { $0.updatedAt > $1.updatedAt }.first
    }
}

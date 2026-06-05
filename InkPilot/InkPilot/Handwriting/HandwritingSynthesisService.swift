import Foundation
import PencilKit
import os.log

/// Errors surfaced by the synthesis pipeline.
enum HandwritingSynthesisError: Error, LocalizedError {
    case profileNotFound
    case noSamples
    case storeReadFailed(underlying: Error)
    case renderFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .profileNotFound: return "Handwriting profile not found."
        case .noSamples: return "No handwriting samples captured yet."
        case .storeReadFailed(let error): return "Could not load samples: \(error.localizedDescription)"
        case .renderFailed(let error): return "Could not render handwriting: \(error.localizedDescription)"
        }
    }
}

/// Synthesizes a PKDrawing from text using a user's stroke-level profile.
///
/// The contract: given a profile (whose samples are on disk) and a string,
/// produce a PencilKit drawing whose strokes look like the user's hand.
///
/// Implementations may use:
///   V0.1.5 — sample stitching with bounded jitter (LocalHandwritingRenderer)
///   V0.2   — a local writer-profile model (Core ML / MLX) to generate new strokes
///   V0.3   — Chinese component-level composition
protocol HandwritingSynthesisService: Sendable {
    /// Render the given text in the user's hand.
    /// - Parameters:
    ///   - text: The text to render.
    ///   - profileID: The user's handwriting profile to use.
    ///   - bounds: The size of the canvas region the drawing should fit inside.
    /// - Returns: A PKDrawing in `bounds` coordinate space.
    func synthesize(
        text: String,
        profileID: UUID,
        bounds: CGSize
    ) async throws -> PKDrawing
}

/// Convenience default bounds for synthesis when the caller doesn't care.
enum HandwritingSynthesisDefaults {
    /// Default output size when synthesizing for an AI suggestion card.
    static let cardBounds = CGSize(width: 260, height: 120)
    /// Default output size for a full-width canvas label.
    static let labelBounds = CGSize(width: 360, height: 80)
    /// Default output size for a mind-map node.
    static let mindNodeBounds = CGSize(width: 180, height: 80)

    static let logger = Logger(subsystem: "com.inkpilot.handwriting", category: "Synthesis")
}

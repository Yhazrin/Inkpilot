import Foundation
import PencilKit
import os.log

/// Concrete synthesis service: stitches the user's captured stroke samples
/// into a PKDrawing with light, bounded randomization. No ML, no remote calls.
///
/// V0.1.5 ships this implementation only. V0.2 will add a `ModelHandwritingRenderer`
/// that uses a local writer-profile model to generate strokes for unseen characters.
final class LocalHandwritingRenderer: HandwritingSynthesisService {

    // MARK: - Properties
    private let store: HandwritingSampleStore.Type
    private let layoutEngine: HandwritingLayoutEngine
    private let logger: Logger

    init(
        store: HandwritingSampleStore.Type = HandwritingSampleStore.self,
        layoutEngine: HandwritingLayoutEngine = HandwritingLayoutEngine(),
        logger: Logger = HandwritingSynthesisDefaults.logger
    ) {
        self.store = store
        self.layoutEngine = layoutEngine
        self.logger = logger
    }

    // MARK: - Synthesis

    func synthesize(
        text: String,
        profileID: UUID,
        bounds: CGSize
    ) async throws -> PKDrawing {
        var library = StrokeGlyphLibrary(profileID: profileID)

        do {
            try library.loadFromStore()
        } catch {
            throw HandwritingSynthesisError.storeReadFailed(underlying: error)
        }

        guard library.stats.characters > 0 else {
            throw HandwritingSynthesisError.noSamples
        }

        // Pre-warm the cache for the characters we'll need.
        let characters = Array(Set(text.filter { !$0.isWhitespace && $0 != "\n" }))
        library.prewarm(forCharacters: characters.map(String.init))

        do {
            let result = try layoutEngine.layout(
                text: text,
                library: &library,
                bounds: bounds
            )
            if !result.usedFallbacks.isEmpty {
                logger.warning("Handwriting synthesis used fallbacks for: \(result.usedFallbacks.joined(), privacy: .public)")
            }
            return result.drawing
        } catch HandwritingLayoutEngine.LayoutError.emptyText {
            return PKDrawing()
        } catch HandwritingLayoutEngine.LayoutError.noSamples {
            throw HandwritingSynthesisError.noSamples
        } catch {
            throw HandwritingSynthesisError.renderFailed(underlying: error)
        }
    }
}

/// Async/sync bridge that lets callers grab a synthesis service
/// without owning the lifecycle.
enum HandwritingServiceLocator {
    /// Default synthesis service — sample stitching.
    static let shared: any HandwritingSynthesisService = LocalHandwritingRenderer()
}

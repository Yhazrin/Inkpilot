import Foundation
import PencilKit
import CoreGraphics

/// Stroke self-correction via Chaikin's corner-cutting algorithm.
///
/// Procreate's "StreamLine", Concepts, Linea Sketch, and most pro
/// sketching apps run a similar post-stroke smoothing pass. PencilKit's
/// `PKStrokePath` is already Hermite-interpolated between control
/// points, so what remains is hand-wobble in the sampled points
/// themselves. Chaikin cuts the wobble by inserting new points at
/// 1/4 and 3/4 of each segment, replacing the originals.
///
/// Two iterations gives a clean, hand-drawn-but-stable look. More
/// iterations start to look mechanical. Fewer iterations and the
/// stroke still trembles.
///
/// Note: `PKStrokePath` does not expose its raw control points publicly
/// (Apple's bridged API only exposes `count`, `creationDate`, and
/// `interpolatedPoints(by:)`). We work on a dense interpolated sample
/// and feed the smoothed result back as the new control points —
/// PencilKit re-Hermite-interpolates them on render, so the visible
/// stroke ends up smoother without ever exposing internals.
enum StrokeSmoother {

    /// Toggle for A/B comparison. Can be flipped at runtime via
    /// `-disableSmoothing` launch flag in DEBUG so QA can switch
    /// on/off without rebuilding.
    static var isEnabled: Bool = true

    /// Number of Chaikin passes per stroke. 2 is the sweet spot.
    static var iterations: Int = 2

    /// Distance (in points) between interpolated samples we feed into
    /// Chaikin. Smaller = denser input = more precise smoothing, but
    /// slower; 2.0 is a good trade-off on iPad-class hardware.
    private static let sampleDistance: CGFloat = 2.0

    /// Apply Chaikin smoothing to a single stroke.
    /// - Returns: a new `PKStroke` with smoothed control points, or
    ///   the original stroke unchanged if disabled / too few points.
    static func smooth(_ stroke: PKStroke) -> PKStroke {
        guard isEnabled, iterations > 0 else { return stroke }
        // The bridged `interpolatedPoints(by:)` returns a lazy slice,
        // not a concrete Array — convert eagerly so Chaikin has a
        // random-access buffer.
        let original: [PKStrokePoint] = Array(
            stroke.path.interpolatedPoints(by: .distance(sampleDistance))
        )
        // Chaikin needs at least 3 points to do meaningful work.
        guard original.count >= 3 else { return stroke }

        var points = original
        for _ in 0..<iterations {
            points = chaikinOnce(points)
        }

        let smoothedPath = PKStrokePath(
            controlPoints: points,
            creationDate: stroke.path.creationDate
        )
        return PKStroke(ink: stroke.ink, path: smoothedPath)
    }

    // MARK: - Chaikin core

    /// One Chaikin pass: for each segment p_i → p_{i+1}, insert
    /// q = 0.75·p_i + 0.25·p_{i+1} and r = 0.25·p_i + 0.75·p_{i+1}.
    /// Anchors the first and last point so the stroke start/end are
    /// exactly where the user lifted the pencil.
    private static func chaikinOnce(_ points: [PKStrokePoint]) -> [PKStrokePoint] {
        guard points.count >= 3 else { return points }
        var out: [PKStrokePoint] = []
        out.reserveCapacity((points.count - 1) * 2 + 2)
        out.append(points[0])
        for i in 0..<(points.count - 1) {
            let a = points[i]
            let b = points[i + 1]
            out.append(mix(a, b, t: 0.25))
            out.append(mix(a, b, t: 0.75))
        }
        out.append(points[points.count - 1])
        return out
    }

    /// Linearly interpolate between two `PKStrokePoint`s at parameter `t`.
    private static func mix(_ a: PKStrokePoint, _ b: PKStrokePoint, t: CGFloat) -> PKStrokePoint {
        let tD = Double(t)
        let size = CGSize(
            width: a.size.width + (b.size.width - a.size.width) * tD,
            height: a.size.height + (b.size.height - a.size.height) * tD
        )
        return PKStrokePoint(
            location: CGPoint(
                x: a.location.x + (b.location.x - a.location.x) * t,
                y: a.location.y + (b.location.y - a.location.y) * t
            ),
            timeOffset: a.timeOffset + (b.timeOffset - a.timeOffset) * tD,
            size: size,
            opacity: a.opacity + (b.opacity - a.opacity) * t,
            force: a.force + (b.force - a.force) * t,
            azimuth: a.azimuth + (b.azimuth - a.azimuth) * t,
            altitude: a.altitude + (b.altitude - a.altitude) * t
        )
    }
}

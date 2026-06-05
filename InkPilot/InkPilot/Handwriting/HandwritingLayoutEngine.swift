import Foundation
import PencilKit
import CoreGraphics

/// Configuration knobs for the layout engine. All randomization is
/// multiplicative or additive within bounded ranges so a sample never
/// looks "broken" — the underlying strokes are still recognizably yours.
struct HandwritingLayoutConfig {
    /// Target height (in points) for a single character glyph.
    var targetGlyphHeight: CGFloat = 36
    /// Random ±jitter on horizontal advance between characters.
    var advanceJitter: ClosedRange<CGFloat> = -2...2
    /// Random ±jitter on vertical baseline drift between characters.
    var baselineJitter: ClosedRange<CGFloat> = -1.5...1.5
    /// Random ±scale factor applied per character.
    var scaleJitter: ClosedRange<CGFloat> = 0.94...1.06
    /// Random ±rotation in degrees applied per character.
    var rotationJitter: ClosedRange<CGFloat> = -3...3
    /// Random ±pressure scale applied per character.
    var pressureJitter: ClosedRange<CGFloat> = 0.85...1.15
    /// Random extra stroke width factor.
    var widthJitter: ClosedRange<CGFloat> = 0.9...1.1
    /// Wrap width (points). nil = single line.
    var lineWrapWidth: CGFloat? = nil
    /// Line height multiplier.
    var lineHeight: CGFloat = 1.5
    /// Top-left margin in the output bounds.
    var margin: CGFloat = 12
    /// Space advance factor (multiplied by glyph height).
    var spaceAdvanceFactor: CGFloat = 0.4
    /// Character width factor (multiplied by glyph height).
    var charWidthFactor: CGFloat = 0.6
    /// Minimum pressure clamp (prevents zero-force strokes).
    var minPressure: CGFloat = 0.05

    static let `default` = HandwritingLayoutConfig()
}

/// Pure layout engine — given a string, a glyph library, and bounds,
/// produce a positioned/translated PKDrawing composed of sampled strokes.
///
/// V0.1.5 is fully deterministic per seed (no ML). Character selection
/// advances round-robin; transform parameters are seeded RNG.
struct HandwritingLayoutEngine {
    let config: HandwritingLayoutConfig

    init(config: HandwritingLayoutConfig = .default) {
        self.config = config
    }

    /// Result of a successful layout. `drawing` is already in the
    /// output coordinate space; `usedFallbacks` flags characters that
    /// had no matching sample (rendered as system text or skipped).
    struct LayoutResult {
        let drawing: PKDrawing
        let lines: [String]
        let usedFallbacks: [String]
    }

    enum LayoutError: Error {
        case noSamples
        case emptyText
    }

    /// Build a PKDrawing rendering of `text` using samples from the library.
    /// The returned drawing is in the coordinate space described by `bounds`.
    func layout(
        text: String,
        library: inout StrokeGlyphLibrary,
        bounds: CGSize,
        seed: UInt64 = UInt64.random(in: 0...UInt64.max)
    ) throws -> LayoutResult {
        guard !text.isEmpty else { throw LayoutError.emptyText }
        guard library.stats.characters > 0 else { throw LayoutError.noSamples }

        var rng = SeededRNG(seed: seed)
        let characters = Array(text)
        let wrapWidth = config.lineWrapWidth ?? bounds.width - config.margin * 2

        var lines: [[String]] = [[]]
        var currentX: CGFloat = config.margin
        var currentY: CGFloat = config.margin

        for char in characters {
            if char == "\n" {
                lines.append([])
                currentX = config.margin
                currentY += config.targetGlyphHeight * config.lineHeight
                continue
            }
            if char == " " {
                let spaceAdvance = config.targetGlyphHeight * config.spaceAdvanceFactor
                if currentX + spaceAdvance > config.margin + wrapWidth {
                    lines.append([])
                    currentX = config.margin
                    currentY += config.targetGlyphHeight * config.lineHeight
                } else {
                    currentX += spaceAdvance
                    lines[lines.count - 1].append(" ")
                }
                continue
            }
            let charWidth = config.targetGlyphHeight * config.charWidthFactor
            if currentX + charWidth > config.margin + wrapWidth {
                lines.append([])
                currentX = config.margin
                currentY += config.targetGlyphHeight * config.lineHeight
            }
            lines[lines.count - 1].append(String(char))
            currentX += charWidth
        }

        // Second pass: position the strokes and assemble a PKDrawing.
        var combined = PKDrawing()
        var usedFallbacks: [String] = []
        var glyphIndex = 0
        var xCursor: CGFloat = config.margin
        var yCursor: CGFloat = config.margin

        for (lineIdx, line) in lines.enumerated() {
            xCursor = config.margin
            yCursor = config.margin + CGFloat(lineIdx) * config.targetGlyphHeight * config.lineHeight

            for char in line {
                defer { glyphIndex += 1 }
                let str = String(char)
                if str == " " {
                    xCursor += config.targetGlyphHeight * config.spaceAdvanceFactor
                    continue
                }
                guard let sampleID = pickSampleID(for: str, library: &library, rng: &rng) else {
                    usedFallbacks.append(str)
                    continue
                }
                guard let data = library.drawingData(for: sampleID) else {
                    usedFallbacks.append(str)
                    continue
                }
                guard let sampleDrawing = try? PKDrawing(data: data) else { continue }
                guard let sample = library.sampleMeta(id: sampleID) else { continue }

                let transform = transform(
                    sampleBounds: sample.sourceBounds.cgRect,
                    atX: xCursor,
                    atY: yCursor,
                    rng: &rng
                )

                let transformed = transformDrawing(sampleDrawing, by: transform)
                combined.append(transformed)
                xCursor += config.targetGlyphHeight * config.charWidthFactor
            }
        }

        let linesText = lines.map { $0.joined() }
        return LayoutResult(drawing: combined, lines: linesText, usedFallbacks: usedFallbacks)
    }

    // MARK: - Internals

    private func pickSampleID(
        for character: String,
        library: inout StrokeGlyphLibrary,
        rng: inout SeededRNG
    ) -> UUID? {
        let ids = library.sampleIDs(for: character)
        guard !ids.isEmpty else { return nil }
        if ids.count == 1 { return ids[0] }
        return ids[Int(rng.next(upperBound: UInt64(ids.count)))]
    }

    private struct Affine {
        var scale: CGFloat
        var rotation: CGFloat
        var translation: CGPoint
        var pressureScale: CGFloat
        var widthScale: CGFloat
    }

    private func transform(
        sampleBounds: CGRect,
        atX x: CGFloat,
        atY y: CGFloat,
        rng: inout SeededRNG
    ) -> Affine {
        let safeHeight = max(sampleBounds.height, 1)
        let baseScale = config.targetGlyphHeight / safeHeight
        let scaleJ = config.scaleJitter.random(using: &rng)
        let rotJ = config.rotationJitter.random(using: &rng)
        let pressureJ = config.pressureJitter.random(using: &rng)
        let widthJ = config.widthJitter.random(using: &rng)
        let advanceJ = config.advanceJitter.random(using: &rng)
        let baselineJ = config.baselineJitter.random(using: &rng)

        let finalScale = baseScale * scaleJ
        // Center the glyph at (x + advanceJ, y + baselineJ).
        let targetCenterX = x + advanceJ + (config.targetGlyphHeight * config.charWidthFactor) / 2
        let targetCenterY = y + baselineJ + config.targetGlyphHeight / 2
        let sourceCenterX = sampleBounds.midX
        let sourceCenterY = sampleBounds.midY
        let translation = CGPoint(
            x: targetCenterX - sourceCenterX * finalScale,
            y: targetCenterY - sourceCenterY * finalScale
        )
        return Affine(
            scale: finalScale,
            rotation: rotJ * .pi / 180,
            translation: translation,
            pressureScale: pressureJ,
            widthScale: widthJ
        )
    }

    private func transformDrawing(_ drawing: PKDrawing, by t: Affine) -> PKDrawing {
        var out = PKDrawing()
        var combined: [PKStroke] = []
        for stroke in drawing.strokes {
            let newPath = transformStrokePath(stroke.path, by: t)
            let newStroke = PKStroke(ink: stroke.ink, path: newPath)
            combined.append(newStroke)
        }
        out.strokes = combined
        return out
    }

    private func transformStrokePath(
        _ path: PKStrokePath,
        by t: Affine
    ) -> PKStrokePath {
        let count = path.count
        guard count > 0 else { return path }
        var points: [PKStrokePoint] = []
        points.reserveCapacity(count)
        for index in 0..<count {
            let p = path[index]
            let rotated = CGPoint(
                x: p.location.x * t.scale * cos(t.rotation) - p.location.y * t.scale * sin(t.rotation),
                y: p.location.x * t.scale * sin(t.rotation) + p.location.y * t.scale * cos(t.rotation)
            )
            let newLocation = CGPoint(
                x: rotated.x + t.translation.x,
                y: rotated.y + t.translation.y
            )
            let newPressure = min(1.0, max(config.minPressure, p.force * t.pressureScale))
            points.append(
                PKStrokePoint(
                    location: newLocation,
                    timeOffset: p.timeOffset,
                    size: CGSize(width: p.size.width * t.widthScale, height: p.size.height * t.widthScale),
                    opacity: p.opacity,
                    force: newPressure,
                    azimuth: p.azimuth,
                    altitude: p.altitude
                )
            )
        }
        return PKStrokePath(controlPoints: points, creationDate: path.creationDate)
    }
}

extension StrokeGlyphLibrary {
    /// Helper used by the layout engine to recover a sample by ID.
    func sampleMeta(id: UUID) -> HandwritingSample? {
        for list in samplesByCharacter.values {
            if let match = list.first(where: { $0.id == id }) {
                return match
            }
        }
        return nil
    }
}

// MARK: - Seeded RNG

/// Tiny xorshift64 RNG. Deterministic per seed, sufficient for layout jitter.
struct SeededRNG {
    private var state: UInt64
    init(seed: UInt64) {
        self.state = seed == 0 ? 0xdeadbeef : seed
    }
    mutating func next() -> UInt64 {
        var x = state
        x ^= x << 13
        x ^= x >> 7
        x ^= x << 17
        state = x
        return x
    }
    mutating func next(upperBound: UInt64) -> UInt64 {
        guard upperBound > 0 else { return 0 }
        return next() % upperBound
    }
    mutating func unitDouble() -> Double {
        Double(next() >> 11) / Double(1 << 53)
    }
}

extension ClosedRange where Bound == CGFloat {
    func random(using rng: inout SeededRNG) -> CGFloat {
        let lo = Double(lowerBound)
        let hi = Double(upperBound)
        return CGFloat(lo + (hi - lo) * rng.unitDouble())
    }
}

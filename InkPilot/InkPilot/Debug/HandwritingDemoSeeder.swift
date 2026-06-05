#if DEBUG
import Foundation
import PencilKit
import UIKit

/// Seeds demo handwriting samples for testing the calibration flow.
// MARK: - Demo Seeder

/// Debug-only seeder that drops fake PKStroke samples into the active
/// handwriting profile, and injects a synthetic AI suggestion that
/// references those samples. Lets QA exercise the V0.1.5 rendering path
/// without going through the calibration UI.
enum HandwritingDemoSeeder {

    /// Seed the active profile with simple programmatic glyphs for the
    /// characters used by the demo suggestion. Idempotent.
    static func seedActiveProfile() {
        do {
            let profile: HandwritingProfile
            if let existing = try HandwritingSampleStore.activeProfile() {
                profile = existing
            } else {
                profile = try HandwritingSampleStore.createProfile(name: "Demo Profile")
            }
            let existing = try HandwritingSampleStore.loadSamples(for: profile.id)
            let alreadyHave = Set(existing.map(\.character))

            let demoString = "InkPilot renders AI text in your own handwriting."
            for char in demoString {
                if alreadyHave.contains(String(char)) { continue }
                if char == " " || char == "\n" { continue }
                let drawing = makeDemoGlyph(for: char)
                let data = drawing.dataRepresentation()
                _ = try? HandwritingSampleStore.saveSample(
                    character: String(char),
                    drawingData: data,
                    sourceBounds: drawing.bounds,
                    profileID: profile.id
                )
            }
        } catch {
            // Debug-only path — surface nothing to the user.
        }
    }

    /// Build a simple "glyph" for a character by tracing a few straight
    /// line strokes. Not calligraphy — just enough to validate the
    /// stitching pipeline in screenshots/QA.
    private static func makeDemoGlyph(for char: Character) -> PKDrawing {
        var drawing = PKDrawing()
        let ink = PKInk(.pen, color: .black)
        let size = CGSize(width: 40, height: 40)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let strokes = demoStrokes(for: char, center: center, size: size)
        for path in strokes {
            let stroke = PKStroke(ink: ink, path: PKStrokePath(controlPoints: path, creationDate: Date()))
            drawing.strokes.append(stroke)
        }
        return drawing
    }

    private static func demoStrokes(for char: Character, center: CGPoint, size: CGSize) -> [[PKStrokePoint]] {
        let w = size.width, h = size.height
        let baseTime = TimeInterval(0)

        // Vertical line strokes — enough variety for layout jitter to be visible.
        func pt(_ x: CGFloat, _ y: CGFloat, _ t: TimeInterval) -> PKStrokePoint {
            PKStrokePoint(
                location: CGPoint(x: center.x - w / 2 + x, y: center.y - h / 2 + y),
                timeOffset: baseTime + t,
                size: CGSize(width: 4, height: 4),
                opacity: 1,
                force: 0.6,
                azimuth: .pi,
                altitude: .pi / 2
            )
        }

        let hash = abs(char.hashValue)
        let variant = hash % 4
        switch variant {
        case 0:
            // I-shape
            return [[pt(w * 0.5, 0, 0), pt(w * 0.5, h, 0.2)]]
        case 1:
            // L-shape
            return [[pt(0, 0, 0), pt(0, h, 0.2), pt(w, h, 0.4)]]
        case 2:
            // V-shape
            return [[pt(0, 0, 0), pt(w * 0.5, h, 0.2), pt(w, 0, 0.4)]]
        default:
            // Z-shape
            return [[pt(0, 0, 0), pt(w, 0, 0.15), pt(0, h, 0.3), pt(w, h, 0.45)]]
        }
    }
}
#endif

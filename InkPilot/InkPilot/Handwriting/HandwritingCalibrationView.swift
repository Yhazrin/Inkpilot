import SwiftUI
import PencilKit

/// A calibration flow that captures one PKDrawing sample per character.
/// The user traces the prompted character; tapping "Save" persists the
/// drawing as a sample for that character in the active profile.
///
/// V0.1.5 deliberately stores raw PKStroke data — no rasterization, no
/// intermediate image. The sample set is what `HandwritingLayoutEngine`
/// later stitches back into new strings.
struct HandwritingCalibrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var profile: HandwritingProfile?
    @State private var currentIndex: Int = 0
    @State private var drawing = PKDrawing()
    @State private var saveFeedback: String? = nil
    @State private var samplesByCharacter: [String: Int] = [:]

    private let characters: [String] = HandwritingCalibrationSets.basic

    var body: some View {
        NavigationStack {
            VStack(spacing: Brand.spacingL) {
                header
                promptCard
                canvasArea
                controls
                if let saveFeedback {
                    Text(saveFeedback)
                        .font(Brand.captionFont)
                        .foregroundStyle(Brand.inkSecondary)
                        .transition(.opacity)
                }
                Spacer(minLength: 0)
            }
            .padding(Brand.spacingL)
            .background(Brand.canvasBase.ignoresSafeArea())
            .navigationTitle(String(localized: "handwriting.calibration.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "handwriting.calibration.done")) { dismiss() }
                }
            }
            .onAppear { loadProfile() }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: Brand.spacingXS) {
            if let profile {
                Text(profile.name)
                    .font(Brand.titleFont)
                    .foregroundStyle(Brand.inkPrimary)
            } else {
                Text(String(localized: "handwriting.calibration.creatingProfile"))
                    .font(Brand.captionFont)
                    .foregroundStyle(Brand.inkSecondary)
            }
            Text(String(localized: "handwriting.calibration.progress \(currentIndex + 1) \(characters.count)"))
                .font(Brand.captionFont)
                .foregroundStyle(Brand.inkSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var promptCard: some View {
        let character = characters[safe: currentIndex] ?? "?"
        return ZStack {
            RoundedRectangle(cornerRadius: Brand.cornerM, style: .continuous)
                .strokeBorder(Brand.inkPrimary.opacity(Brand.stickyTintOpacity), lineWidth: Brand.thinStrokeWidth)
                .background(
                    RoundedRectangle(cornerRadius: Brand.cornerM).fill(.white)
                )
            VStack(spacing: Brand.spacingS) {
                Text(character)
                    .font(.system(size: 96, weight: .regular, design: .serif))
                    .foregroundStyle(Brand.inkTertiary)
                if let count = samplesByCharacter[character] {
                    Text(String(localized: "handwriting.calibration.savedSamples \(count)"))
                        .font(Brand.captionFont)
                        .foregroundStyle(Brand.inkSecondary)
                }
            }
        }
        .frame(height: Brand.calibrationAreaHeight)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(String(localized: "handwriting.calibration.prompt.accessibility \(character)")))
    }

    private var canvasArea: some View {
        CalibrationCanvas(drawing: $drawing)
            .frame(maxWidth: .infinity)
            .frame(height: Brand.calibrationCanvasHeight)
            .background(
                RoundedRectangle(cornerRadius: Brand.cornerM)
                    .fill(.white)
                    .shadow(color: .black.opacity(Brand.ultraSubtleOpacity), radius: Brand.shadowRadiusMedium, y: Brand.shadowYMedium)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Brand.cornerM)
                    .strokeBorder(Brand.inkPrimary.opacity(0.1), lineWidth: Brand.glassBorderWidth)
            )
    }

    private var controls: some View {
        HStack(spacing: Brand.spacingM) {
            Button {
                drawing = PKDrawing()
                saveFeedback = nil
            } label: {
                Label(String(localized: "handwriting.calibration.clear"), systemImage: "arrow.uturn.backward")
                    .font(Brand.bodyFont)
                    .frame(maxWidth: .infinity, minHeight: Brand.touchTarget)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(Text(String(localized: "handwriting.calibration.clear")))

            Button {
                saveCurrentSample()
            } label: {
                Label(String(localized: "handwriting.calibration.save"), systemImage: "checkmark.circle.fill")
                    .font(Brand.bodyFont)
                    .frame(maxWidth: .infinity, minHeight: Brand.touchTarget)
            }
            .buttonStyle(.borderedProminent)
            .disabled(drawing.strokes.isEmpty || profile == nil)
            .accessibilityLabel(Text(String(localized: "handwriting.calibration.save")))

            Button {
                advance()
            } label: {
                Label(String(localized: "handwriting.calibration.next"), systemImage: "arrow.right")
                    .font(Brand.bodyFont)
                    .frame(maxWidth: .infinity, minHeight: Brand.touchTarget)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(Text(String(localized: "handwriting.calibration.next")))
        }
    }

    // MARK: - Actions

    private func loadProfile() {
        do {
            if let existing = try HandwritingSampleStore.activeProfile() {
                profile = existing
            } else {
                let new = try HandwritingSampleStore.createProfile(name: defaultProfileName)
                profile = new
            }
            let samples = try HandwritingSampleStore.loadSamples(for: profile!.id)
            samplesByCharacter = Dictionary(grouping: samples, by: { $0.character }).mapValues(\.count)
        } catch {
            // Surface error to the user via the feedback label.
            saveFeedback = String(localized: "handwriting.calibration.profileError")
        }
    }

    private var defaultProfileName: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return String(localized: "handwriting.calibration.defaultProfileName \(formatter.string(from: Date()))")
    }

    private func saveCurrentSample() {
        guard let profile else { return }
        let character = characters[safe: currentIndex] ?? "?"
        let bounds = drawing.bounds.isEmpty
            ? CGRect(x: 0, y: 0, width: 200, height: 200)
            : drawing.bounds
        let data = drawing.dataRepresentation()
        do {
            _ = try HandwritingSampleStore.saveSample(
                character: character,
                drawingData: data,
                sourceBounds: bounds,
                profileID: profile.id
            )
            samplesByCharacter[character, default: 0] += 1
            withAnimation(.easeOut(duration: 0.3)) {
                saveFeedback = String(localized: "handwriting.calibration.saved \(character)")
            }
            drawing = PKDrawing()
        } catch {
            saveFeedback = String(localized: "handwriting.calibration.saveError")
        }
    }

    private func advance() {
        guard !characters.isEmpty else { return }
        currentIndex = (currentIndex + 1) % characters.count
        drawing = PKDrawing()
        saveFeedback = nil
    }
}

// MARK: - PencilKit wrapper

private struct CalibrationCanvas: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeCoordinator() -> Coordinator { Coordinator(drawing: $drawing) }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.drawingPolicy = .pencilOnly
        canvas.tool = PKInkingTool(.pen, color: .black, width: 6)
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.delegate = context.coordinator
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        if canvas.drawing != drawing {
            canvas.drawing = drawing
        }
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        init(drawing: Binding<PKDrawing>) { _drawing = drawing }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }
    }
}

// MARK: - Character set

enum HandwritingCalibrationSets {
    /// Lowercase English letters, digits, common punctuation, and a small
    /// starter set of common Chinese characters. Adjust as the user
    /// completes passes and wants more coverage.
    static let basic: [String] = {
        var chars: [String] = []
        chars.append(contentsOf: "abcdefghijklmnopqrstuvwxyz".map { String($0) })
        chars.append(contentsOf: "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) })
        chars.append(contentsOf: "0123456789".map { String($0) })
        chars.append(contentsOf: [".", ",", "!", "?", ";", ":", "-", "—", "…"])
        chars.append(contentsOf: ["的", "我", "你", "是", "在", "有", "和", "不", "了", "中", "大", "为", "上", "个", "国", "人", "这", "们", "到", "说"])
        return chars
    }()
}

// MARK: - Safe subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

import SwiftUI

/// The kind of drawing tool selected.
enum DrawingToolKind: String, CaseIterable, Codable {
    case pen
    case pencil
    case highlighter
    case eraser
}

/// Observable state for the current drawing tool settings.
/// Owned by CanvasViewModel, independent from UI.
@Observable
final class DrawingToolState {
    var selectedKind: DrawingToolKind = .pen
    /// Default ink color adapts to light/dark mode via Brand.inkPrimary.
    var color: Color = Brand.inkPrimary
    var width: CGFloat = 2.0
    var opacity: CGFloat = 1.0
    var eraserMode: EraserMode = .bitmap

    /// Recently used colors for quick access.
    var recentColors: [Color] = [Brand.inkPrimary, .blue, .red]

    /// Recently used widths.
    var recentWidths: [CGFloat] = [1.0, 2.0, 4.0]

    // MARK: - Computed

    /// The effective drawing color (accounts for highlighter opacity).
    var effectiveColor: Color {
        if selectedKind == .highlighter {
            return color.opacity(opacity * Brand.highlighterOpacityMultiplier)
        }
        return color.opacity(opacity)
    }

    /// Whether this tool draws ink (pen/pencil/highlighter).
    var isDrawingTool: Bool {
        selectedKind != .eraser
    }

    // MARK: - Actions

    func selectKind(_ kind: DrawingToolKind) {
        selectedKind = kind
    }

    func selectColor(_ newColor: Color) {
        color = newColor
        // Add to recent if not already present
        recentColors.removeAll { $0 == newColor }
        recentColors.insert(newColor, at: 0)
        if recentColors.count > 6 { recentColors.removeLast() }
    }

    func selectWidth(_ newWidth: CGFloat) {
        width = newWidth
        recentWidths.removeAll { $0 == newWidth }
        recentWidths.insert(newWidth, at: 0)
        if recentWidths.count > 4 { recentWidths.removeLast() }
    }
}

/// Eraser mode options.
enum EraserMode: String, Codable {
    case bitmap
    case vector
}

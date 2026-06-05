import Foundation
#if DEBUG

/// Debug-only launch argument parser for screenshot/QA automation.
///
/// Driven via `simctl launch` extra args, e.g.:
///   xcrun simctl launch booted com.inkpilot.app \
///     -autoCanvas 1 -tool select -useLasso 1 -palette shape
///
/// Never reads or affects release builds.
enum DebugLaunchOptions {

    /// `-autoCanvas 1` or `-autoCanvas` → skip Home and open CanvasView directly.
    static var autoCanvas: Bool {
        args.contains("-autoCanvas") || args.contains("-autoCanvas 1")
    }

    /// `-tool <name>` → set initial selected tool. Names: pen | eraser | select |
    /// text | shape | connector | media. Empty string if not provided.
    static var tool: String? { value(after: "-tool") }

    /// `-useLasso 1` → force lasso selection on in select tool.
    static var useLasso: Bool {
        args.contains("-useLasso") || args.contains("-useLasso 1")
    }

    /// `-palette <name>` → open a palette. Names: shape | media.
    static var palette: String? { value(after: "-palette") }

    /// `-seedObjects 1` → add 4 demo objects (text, sticky, shape, media) at fixed
    /// world positions, to populate the canvas for screenshot capture.
    static var seedObjects: Bool {
        args.contains("-seedObjects") || args.contains("-seedObjects 1")
    }

    /// `-triggerGhost 1` → synthesize a fake ghost suggestion at canvas center.
    static var triggerGhost: Bool {
        args.contains("-triggerGhost") || args.contains("-triggerGhost 1")
    }

    /// `-showExportSheet 1` → open the export share sheet directly on appear.
    static var showExportSheet: Bool {
        args.contains("-showExportSheet") || args.contains("-showExportSheet 1")
    }

    /// `-nukePersist 1` → wipe any persisted canvas document so the canvas
    /// starts empty. Consumed by the App entry.
    static var nukePersist: Bool {
        args.contains("-nukePersist") || args.contains("-nukePersist 1")
    }

    // MARK: - Private

    private static var args: [String] { ProcessInfo.processInfo.arguments }

    private static func value(after flag: String) -> String? {
        guard let idx = args.firstIndex(of: flag), idx + 1 < args.count else { return nil }
        let next = args[idx + 1]
        return next.hasPrefix("-") ? nil : next
    }
}

#endif

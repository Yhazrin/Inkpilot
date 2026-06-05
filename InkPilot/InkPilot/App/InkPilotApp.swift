import SwiftUI

/// InkPilot app entry point.
@main
struct InkPilotApp: App {
    init() {
        // DEBUG-only launch flags. Read once at launch so QA can
        // toggle behavior without rebuilding. In Release these are
        // compiled out and the defaults stand.
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-disableSmoothing") {
            StrokeSmoother.isEnabled = false
        }
        if args.contains("-smoothing1") {
            StrokeSmoother.iterations = 1
        }
        if args.contains("-smoothing3") {
            StrokeSmoother.iterations = 3
        }
        if args.contains("-seedHandwriting") || args.contains("-seedHandwriting 1") {
            HandwritingDemoSeeder.seedActiveProfile()
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

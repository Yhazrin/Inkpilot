import SwiftUI

/// The main canvas screen — InkPilot's core product surface.
///
/// Layer composition (bottom → top), per the V0.1 motion spec:
///
///   1. ColorBlockBackground        — flat spatial canvas
///   2. PencilKitCanvasRepresentable  — handwriting
///   3. CanvasMotionLayer            — scan aura / source glow / trace
///   4. AcceptedCardsOverlay         — flat canvas objects
///   5. Floating chrome              — toolbar / prompt / AI panel
///   6. GhostSuggestionCard          — anchored, born from ink
///
/// The view layer is also responsible for one piece of timing that
/// the view model deliberately does not own: clearing
/// `suggestionAnchor` after the exit and materialize motions have had
/// a chance to sample it. We do this with one-shot `Task.sleep` driven
/// by `.onChange`, never with a recursive loop.
struct CanvasView: View {
    @State private var viewModel = CanvasViewModel()

    /// Number of accepted-card insertion events. We pass this into
    /// `CanvasMotionLayer` to retrigger the materialization trace.
    @State private var lastMaterializationCount: Int = 0

    var body: some View {
        ZStack {
            // 1. Background
            ColorBlockBackground()

            // 2. PencilKit drawing
            PencilKitCanvasRepresentable(
                drawing: $viewModel.drawing,
                tool: viewModel.selectedTool
            )
            .ignoresSafeArea()

            // 3. Non-interactive motion effects
            CanvasMotionLayer(
                anchor: viewModel.suggestionAnchor?.cgPoint,
                isThinking: viewModel.isThinking,
                hasGhost: viewModel.ghostSuggestion != nil,
                materializationCount: lastMaterializationCount
            )

            // 4. Accepted cards (canvas objects, above motion)
            if !viewModel.acceptedCards.isEmpty {
                AcceptedCardsOverlay(
                    cards: viewModel.acceptedCards,
                    sourceAnchor: viewModel.suggestionAnchor?.cgPoint
                )
            }

            // 5. Floating chrome
            floatingChrome

            // 6. Ghost suggestion card (anchor-anchored, not centered)
            if let suggestion = viewModel.ghostSuggestion,
               let anchor = viewModel.suggestionAnchor?.cgPoint {
                GhostSuggestionCard(
                    suggestion: suggestion,
                    anchor: anchor,
                    target: ghostTargetPosition(for: anchor),
                    onAccept: { viewModel.acceptSuggestion() },
                    onDismiss: { viewModel.dismissSuggestion() }
                )
            }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.ghostSuggestion) { _, newValue in
            // When the ghost is dismissed/accepted, clear the anchor
            // after the exit motion has had a chance to sample it.
            // One-shot Task.sleep — never a recursive loop.
            if newValue == nil {
                let delay = MotionTokens.anchorExitDelay
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    if viewModel.ghostSuggestion == nil {
                        viewModel.suggestionAnchor = nil
                    }
                }
            }
        }
        .onChange(of: viewModel.acceptedCards.count) { _, newCount in
            // Bump the materialization trace trigger, and clear the
            // anchor after the materialize has had time to read it.
            lastMaterializationCount = newCount
            let delay = MotionTokens.anchorMaterializeDelay
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                viewModel.suggestionAnchor = nil
            }
        }
        #if DEBUG
        // Debug-only launch flags for screenshot capture. No-op in
        // Release. `-autoCanvas 1` skips Home; `-autoExpandAI` opens
        // the AI panel; `-autoTriggerAI` kicks a suggestion; the
        // negative one accepts it for a materialize screenshot.
        .onAppear {
            let args = ProcessInfo.processInfo.arguments
            if args.contains("-autoCanvas") || args.contains("-autoCanvas 1") {
                // HomeView checks this; nothing to do here.
            }
            if args.contains("-autoExpandAI") {
                viewModel.isAIPanelExpanded = true
            }
            if args.contains("-autoTriggerAI") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.requestSuggestion()
                }
            }
            if args.contains("-autoAcceptAI") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    viewModel.requestSuggestion()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                    viewModel.acceptSuggestion()
                }
            }
        }
        #endif
    }

    // MARK: - Floating Chrome Layer

    private var floatingChrome: some View {
        VStack {
            // Top: Floating toolbar
            CanvasToolbar(viewModel: viewModel)
                .padding(.top, Brand.spacingM)

            Spacer()

            // Bottom: Prompt capsule
            CanvasPromptBar(viewModel: viewModel)
                .padding(.bottom, Brand.spacingL)
        }
        .overlay(alignment: .bottomTrailing) {
            // Right side: AI Pilot panel (chip ↔ panel via matched geometry)
            AIPilotPanel(viewModel: viewModel)
                .padding(.trailing, Brand.spacingL)
                .padding(.bottom, 100)
        }
    }

    // MARK: - Ghost target placement

    /// Where the ghost card should land relative to the suggestion
    /// anchor. Offset down/right so the card does not cover the ink
    /// it was born from. The card is still visibly anchored to the
    /// source via the emerge travel vector.
    private func ghostTargetPosition(for anchor: CGPoint) -> CGPoint {
        CGPoint(x: anchor.x + 220, y: anchor.y + 40)
    }
}

#Preview {
    CanvasView()
}

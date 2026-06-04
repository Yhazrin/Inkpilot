import SwiftUI

/// The main canvas screen — InkPilot's core product surface.
///
/// Layer composition (bottom → top):
///   1. ColorBlockBackground (with ambient breath)
///   2. PencilKit drawing surface
///   3. CanvasMotionLayer — the scan aura around the suggestion anchor
///   4. Floating chrome: toolbar, prompt, AI panel
///   5. Ghost suggestion card (emerges from the suggestion anchor)
///   6. Accepted cards (materialize from the suggestion anchor)
struct CanvasView: View {
    @State private var viewModel = CanvasViewModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Layer 1: Spatial background (with breath)
            ColorBlockBackground()

            // Layer 2: PencilKit drawing
            PencilKitCanvasRepresentable(
                drawing: $viewModel.drawing,
                tool: viewModel.selectedTool
            )
            .ignoresSafeArea()

            // Layer 3: Scan aura around the suggestion anchor
            CanvasMotionLayer(
                anchor: viewModel.suggestionAnchor?.cgPoint,
                isThinking: viewModel.isThinking
            )

            // Layer 4: Floating chrome
            floatingChrome
        }
        .navigationBarHidden(true)
        #if DEBUG
        // Debug-only: `-autoExpandAI` opens the AI panel; `-autoTriggerAI`
        // also kicks the suggestion. Both used for screenshot capture.
        .onAppear {
            let args = ProcessInfo.processInfo.arguments
            if args.contains("-autoExpandAI") {
                viewModel.isAIPanelExpanded = true
            }
            if args.contains("-autoTriggerAI") {
                // Defer so the canvas has time to lay out.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.requestSuggestion()
                }
            }
            if args.contains("-autoAcceptAI") {
                // Defer so the ghost has time to land, then accept.
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
        .overlay {
            // Ghost suggestion card overlay — emerges from suggestionAnchor
            if let suggestion = viewModel.ghostSuggestion,
               let anchorCG = viewModel.suggestionAnchor?.cgPoint {
                GhostSuggestionCard(
                    suggestion: suggestion,
                    anchor: anchorCG,
                    target: ghostTargetPosition(for: anchorCG),
                    onAccept: { viewModel.acceptSuggestion() },
                    onDismiss: { viewModel.dismissSuggestion() }
                )
                .frame(maxWidth: 380)
            }
        }
        .overlay {
            // Accepted cards overlay — materialize from suggestionAnchor
            if !viewModel.acceptedCards.isEmpty {
                AcceptedCardsOverlay(
                    cards: viewModel.acceptedCards,
                    sourceAnchor: viewModel.suggestionAnchor?.cgPoint
                )
            }
        }
    }

    // MARK: - Ghost target placement

    /// Where the ghost card should land relative to the suggestion anchor.
    /// The card is offset down + to the right of the anchor so it doesn't
    /// cover the ink, but it visibly travels *from* the anchor to here.
    private func ghostTargetPosition(for anchor: CGPoint) -> CGPoint {
        CGPoint(
            x: anchor.x + 220,
            y: anchor.y + 40
        )
    }
}

#Preview {
    CanvasView()
}

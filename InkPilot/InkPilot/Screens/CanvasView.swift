import SwiftUI

/// The main canvas screen — InkPilot's core product surface.
/// Composes background, PencilKit layer, floating toolbar, prompt capsule, and AI panel.
struct CanvasView: View {
    @State private var viewModel = CanvasViewModel()

    var body: some View {
        ZStack {
            // Layer 1: Spatial background
            ColorBlockBackground()

            // Layer 2: PencilKit drawing
            PencilKitCanvasRepresentable(
                drawing: $viewModel.drawing,
                tool: viewModel.selectedTool
            )
            .ignoresSafeArea()

            // Layer 3: Floating chrome
            floatingChrome
        }
        .navigationBarHidden(true)
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
            // Right side: AI Pilot panel
            AIPilotPanel(viewModel: viewModel)
                .padding(.trailing, Brand.spacingL)
                .padding(.bottom, 100)
        }
        .overlay {
            // Ghost suggestion card overlay
            if let suggestion = viewModel.ghostSuggestion {
                GhostSuggestionCard(
                    suggestion: suggestion,
                    onAccept: { viewModel.acceptSuggestion() },
                    onDismiss: { viewModel.dismissSuggestion() }
                )
                .frame(maxWidth: 380)
                .padding(.horizontal, Brand.spacingXL)
            }
        }
        .overlay {
            // Accepted cards overlay — positions itself via worldPosition on each card
            if !viewModel.acceptedCards.isEmpty {
                AcceptedCardsOverlay(cards: viewModel.acceptedCards)
            }
        }
    }
}

#Preview {
    CanvasView()
}

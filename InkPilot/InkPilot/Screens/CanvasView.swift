import SwiftUI

/// The main canvas screen — InkPilot's core product surface.
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
            .allowsHitTesting(viewModel.selectedTool == .pen || viewModel.selectedTool == .eraser)

            // Layer 3: Canvas objects
            CanvasObjectLayer(
                objects: viewModel.canvasObjects,
                selectedID: viewModel.selectedObjectID,
                isSelectToolActive: viewModel.selectedTool == .select,
                onSelect: { viewModel.selectObject($0) },
                onMove: { id, pos in viewModel.moveObject(id: id, to: pos) }
            )

            // Layer 4: Floating chrome
            floatingChrome
        }
        .navigationBarHidden(true)
    }

    // MARK: - Floating Chrome Layer

    private var floatingChrome: some View {
        VStack {
            // Top: Toolbar + secondary palettes
            VStack(spacing: Brand.spacingS) {
                CanvasToolbar(viewModel: viewModel)

                if viewModel.isShapePaletteVisible {
                    ShapePalette(
                        onSelect: { kind in
                            let obj = CanvasObjectFactory.shape(kind: kind, at: CGPointCodable(x: 500, y: 400))
                            viewModel.addObject(obj)
                            viewModel.isShapePaletteVisible = false
                        },
                        onClose: { viewModel.isShapePaletteVisible = false }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                if viewModel.isMediaPaletteVisible {
                    MediaPalette(
                        onSelect: { type in
                            let obj: CanvasObject = type == .image
                                ? CanvasObjectFactory.imagePlaceholder(at: CGPointCodable(x: 500, y: 400))
                                : CanvasObjectFactory.filePlaceholder(at: CGPointCodable(x: 500, y: 400))
                            viewModel.addObject(obj)
                            viewModel.isMediaPaletteVisible = false
                        },
                        onClose: { viewModel.isMediaPaletteVisible = false }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.top, Brand.spacingM)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.isShapePaletteVisible)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.isMediaPaletteVisible)

            Spacer()

            // Bottom: Prompt capsule + object action bar
            VStack(spacing: Brand.spacingS) {
                if viewModel.selectedObjectID != nil {
                    ObjectActionBar(
                        onDelete: { viewModel.deleteSelected() },
                        onDuplicate: { viewModel.duplicateSelected() },
                        onDeselect: { viewModel.selectObject(nil) }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                CanvasPromptBar(viewModel: viewModel)
            }
            .padding(.bottom, Brand.spacingL)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.selectedObjectID)
        }
        .overlay(alignment: .bottomTrailing) {
            AIPilotPanel(viewModel: viewModel)
                .padding(.trailing, Brand.spacingL)
                .padding(.bottom, 100)
        }
        .overlay {
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
    }
}

// MARK: - Object Action Bar

private struct ObjectActionBar: View {
    var onDelete: () -> Void
    var onDuplicate: () -> Void
    var onDeselect: () -> Void

    var body: some View {
        GlassCapsule {
            Button(action: onDuplicate) {
                Image(systemName: "plus.square.on.square")
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text(String(localized: "action.duplicate")))

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .frame(width: 44, height: 44)
                    .foregroundStyle(.red)
            }
            .accessibilityLabel(Text(String(localized: "action.delete")))

            Divider().frame(height: 20)

            Button(action: onDeselect) {
                Image(systemName: "xmark.circle")
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text(String(localized: "action.deselect")))
        }
    }
}

#Preview {
    CanvasView()
}

import SwiftUI

/// The main canvas screen — InkPilot's core product surface.
///
/// Layer order (bottom → top):
///   1. ColorBlockBackground
///   2. PencilKitCanvasRepresentable
///   3. CanvasMotionLayer
///   4. CanvasObjectLayer
///   5. Floating chrome (toolbar, palettes, prompt, AI panel)
///   6. GhostSuggestionCard (anchor-anchored)
struct CanvasView: View {
    @State private var viewModel = CanvasViewModel()
    @State private var materializationCount: Int = 0

    var body: some View {
        ZStack {
            // 1. Background
            ColorBlockBackground()

            // 2. PencilKit drawing (pencilOnly — fingers pass through)
            PencilKitCanvasRepresentable(
                drawing: $viewModel.drawing,
                tool: viewModel.selectedTool,
                onTransformChange: { scale, offset in
                    viewModel.syncTransform(scale: scale, offset: offset)
                }
            )
            .ignoresSafeArea()

            // 3. Non-interactive motion effects (transform-aware anchor)
            CanvasMotionLayer(
                anchor: viewModel.suggestionAnchor.map {
                    viewModel.worldToScreen($0.cgPoint)
                },
                isThinking: viewModel.isThinking,
                hasGhost: viewModel.ghostSuggestion != nil,
                materializationCount: materializationCount
            )

            // 4. Canvas objects (above motion, below chrome)
            CanvasObjectLayer(
                objects: viewModel.canvasObjects,
                selectedID: viewModel.selectedObjectID,
                editingID: viewModel.editingObjectID,
                isSelectToolActive: viewModel.selectedTool == .select,
                isConnectorToolActive: viewModel.selectedTool == .shape,
                connectorStartID: viewModel.connectorStartID,
                sourceAnchor: viewModel.suggestionAnchor?.cgPoint,
                transform: viewModel.canvasTransform,
                onSelect: { viewModel.selectObject($0) },
                onConnectorTap: { viewModel.handleConnectorTap($0) },
                onBeginEditing: { viewModel.beginEditing($0) },
                onEndEditing: { viewModel.endEditing() },
                onTextChange: { id, text in viewModel.updateObjectText(id: id, newText: text) },
                onMove: { id, pos in viewModel.moveObject(id: id, to: pos) },
                onResize: { id, size in viewModel.resizeObject(id: id, to: size) }
            )

            // 5. Floating chrome
            floatingChrome

            // 6. Ghost suggestion (anchor-anchored, transform-aware)
            if let suggestion = viewModel.ghostSuggestion,
               let anchor = viewModel.suggestionAnchor?.cgPoint {
                let screenAnchor = viewModel.worldToScreen(anchor)
                GhostSuggestionCard(
                    suggestion: suggestion,
                    anchor: screenAnchor,
                    target: ghostTarget(for: screenAnchor),
                    onAccept: { viewModel.acceptSuggestion() },
                    onDismiss: { viewModel.dismissSuggestion() }
                )
            }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.ghostSuggestion) { _, newValue in
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
        .onChange(of: viewModel.canvasObjects.count) { _, newCount in
            materializationCount = newCount
            let delay = MotionTokens.anchorMaterializeDelay
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                viewModel.suggestionAnchor = nil
            }
        }
        #if DEBUG
        // Debug-only launch flags for screenshot capture. No-op in
        // Release. `-autoTriggerAI` kicks a suggestion; `-autoAcceptAI`
        // triggers then accepts for a materialize screenshot.
        .onAppear {
            let args = ProcessInfo.processInfo.arguments
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

    // MARK: - Floating Chrome

    private var floatingChrome: some View {
        VStack {
            VStack(spacing: Brand.spacingS) {
                CanvasToolbar(viewModel: viewModel)

                if viewModel.isShapePaletteVisible {
                    ShapePalette(
                        onSelect: { kind in
                            let obj = CanvasObjectFactory.shape(
                                kind: kind,
                                at: viewModel.defaultInsertionPoint
                            )
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
                                ? CanvasObjectFactory.imagePlaceholder(at: viewModel.defaultInsertionPoint)
                                : CanvasObjectFactory.filePlaceholder(at: viewModel.defaultInsertionPoint)
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
    }

    // MARK: - Ghost placement

    private func ghostTarget(for anchor: CGPoint) -> CGPoint {
        CGPoint(x: anchor.x + 220, y: anchor.y + 40)
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
                Image(systemName: "plus.square.on.square").frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text(String(localized: "action.duplicate")))

            Button(action: onDelete) {
                Image(systemName: "trash").frame(width: 44, height: 44).foregroundStyle(.red)
            }
            .accessibilityLabel(Text(String(localized: "action.delete")))

            Divider().frame(height: 20)

            Button(action: onDeselect) {
                Image(systemName: "xmark.circle").frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text(String(localized: "action.deselect")))
        }
    }
}

#Preview {
    CanvasView()
}

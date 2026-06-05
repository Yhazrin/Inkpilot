import SwiftUI

/// The main canvas screen — InkPilot's core product surface.
/// Composes background, PencilKit, motion, objects, marquee/lasso, guides, chrome.
struct CanvasView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CanvasViewModel()
    @State private var materializationCount: Int = 0
    @State private var marqueeStart: CGPoint?
    @State private var marqueeEnd: CGPoint?
    @State private var showExportSheet = false
    @State private var exportURL: URL?

    var body: some View {
        ZStack {
            // 1. Background
            ColorBlockBackground()

            // 2. PencilKit drawing
            PencilKitCanvasRepresentable(
                drawing: $viewModel.drawing,
                tool: viewModel.selectedTool,
                drawingToolState: viewModel.drawingToolState,
                onTransformChange: { scale, offset in
                    viewModel.syncTransform(scale: scale, offset: offset)
                }
            )
            .ignoresSafeArea()
            .onChange(of: viewModel.drawing) { _, _ in viewModel.autoSave() }

            // 3. Empty canvas hint
            if viewModel.drawing.strokes.isEmpty && viewModel.canvasObjects.isEmpty {
                emptyCanvasHint
            }

            // 4. Motion effects
            CanvasMotionLayer(
                anchor: viewModel.suggestionAnchor.map { viewModel.worldToScreen($0.cgPoint) },
                isThinking: viewModel.isThinking,
                hasGhost: viewModel.ghostSuggestion != nil,
                materializationCount: materializationCount
            )

            // 4. Canvas objects
            // Text tool: tap empty canvas to insert text box
            if viewModel.selectedTool == .text {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        let worldPos = viewModel.screenToWorld(location)
                        let obj = CanvasObjectFactory.textBox(at: CGPointCodable(x: worldPos.x, y: worldPos.y))
                        viewModel.addObject(obj)
                    }
            }
            CanvasObjectLayer(
                objects: viewModel.canvasObjects,
                selectedIDs: viewModel.selection.selectedIDs,
                editingID: viewModel.selection.editingID,
                isSelectToolActive: viewModel.selectedTool == .select,
                isConnectorToolActive: viewModel.selectedTool == .connector,
                connectorStartID: viewModel.connectorStartID,
                sourceAnchor: viewModel.suggestionAnchor?.cgPoint,
                transform: viewModel.canvasTransform,
                actions: CanvasObjectActions(
                    onSelect: { viewModel.selection.selectObject($0) },
                    onToggleSelection: { viewModel.selection.toggleSelection($0) },
                    onGroupTap: { viewModel.selection.selectGroup($0, allObjects: viewModel.canvasObjects) },
                    onConnectorTap: { viewModel.handleConnectorTap($0) },
                    onBeginEditing: { viewModel.selection.beginEditing($0) },
                    onEndEditing: { viewModel.selection.endEditing() },
                    onTextChange: { id, text in viewModel.updateObjectText(id: id, newText: text) },
                    onMove: { id, pos in viewModel.moveObjectWithGuides(id: id, to: pos) },
                    onMoveSelected: { delta in viewModel.moveSelectedObjects(by: delta) },
                    onDragStart: { viewModel.pushHistoryBeforeMove() },
                    onDragEnd: { viewModel.clearGuides() },
                    onResize: { id, size in viewModel.resizeObject(id: id, to: size) },
                    onResizeStart: { viewModel.pushHistoryBeforeResize() }
                )
            )

            // 5. Smart guide lines
            GuideOverlay(guides: viewModel.activeGuides, transform: viewModel.canvasTransform)

            // 5b. Tap empty canvas to deselect (only in select mode)
            if viewModel.selectedTool == .select && viewModel.selection.hasSelection {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selection.clearSelection()
                    }
                    .allowsHitTesting(true)
            }

            // 6. Selection layer (marquee or lasso)
            if viewModel.selectedTool == .select {
                selectionLayer
            }

            // 7. Tool mode hints
            if viewModel.selectedTool == .connector {
                toolModeHint(String(localized: "tool.connector.hint"))
            } else if viewModel.selectedTool == .text {
                toolModeHint(String(localized: "tool.text.hint"))
            } else if viewModel.selectedTool == .shape && !viewModel.isShapePaletteVisible {
                toolModeHint(String(localized: "tool.shape.hint"))
            } else if viewModel.selectedTool == .media && !viewModel.isMediaPaletteVisible {
                toolModeHint(String(localized: "tool.media.hint"))
            }

            // 8. Floating chrome
            CanvasFloatingChrome(
                viewModel: viewModel,
                onDismiss: { dismiss() },
                showExportSheet: $showExportSheet,
                exportURL: $exportURL
            )

            // 8. Ghost suggestion card
            if let suggestion = viewModel.ghostSuggestion,
               let anchor = viewModel.suggestionAnchor?.cgPoint {
                GeometryReader { geo in
                    let screenAnchor = viewModel.worldToScreen(anchor)
                    let rawTarget = CGPoint(x: screenAnchor.x + 220, y: screenAnchor.y + 40)
                    let cardHalfWidth = Brand.ghostCardMaxWidth / 2
                    let cardHalfHeight: CGFloat = 120
                    let clampedTarget = CGPoint(
                        x: min(max(rawTarget.x, cardHalfWidth), geo.size.width - cardHalfWidth),
                        y: min(max(rawTarget.y, cardHalfHeight), geo.size.height - cardHalfHeight)
                    )
                    GhostSuggestionCard(
                        suggestion: suggestion,
                        anchor: screenAnchor,
                        target: clampedTarget,
                        onAccept: { viewModel.acceptSuggestion() },
                        onDismiss: { viewModel.dismissSuggestion() }
                    )
                }
            }
        }
        .navigationBarHidden(true)
        // Keyboard shortcuts for iPad + Magic Keyboard
        .background {
            VStack {
                Button("") { viewModel.undo() }
                    .keyboardShortcut("z", modifiers: .command)
                Button("") { viewModel.redo() }
                    .keyboardShortcut("z", modifiers: [.command, .shift])
                Button("") { viewModel.deleteSelected() }
                    .keyboardShortcut(.delete, modifiers: [])
                Button("") { viewModel.duplicateSelected() }
                    .keyboardShortcut("d", modifiers: .command)
                Button("") { viewModel.selectAllObjects() }
                    .keyboardShortcut("a", modifiers: .command)
            }
            .frame(width: 0, height: 0)
            .opacity(0)
            .accessibilityHidden(true)
        }
        .sheet(isPresented: $showExportSheet) {
            if let exportURL { ShareSheet(items: [exportURL]) }
        }
        .onChange(of: viewModel.ghostSuggestion) { _, newValue in
            if newValue == nil {
                let delay = MotionTokens.anchorExitDelay
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    if viewModel.ghostSuggestion == nil { viewModel.suggestionAnchor = nil }
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
    }

    // MARK: - Selection Layer

    @ViewBuilder
    private var selectionLayer: some View {
        if viewModel.useLasso {
            LassoSelectionLayer(
                isActive: true,
                transform: viewModel.canvasTransform,
                lassoPoints: $viewModel.lassoPoints,
                onLassoComplete: { points in viewModel.selectObjectsInLasso(points) }
            )
        } else {
            SelectionMarqueeLayer(
                isActive: true,
                transform: viewModel.canvasTransform,
                marqueeStart: $marqueeStart,
                marqueeEnd: $marqueeEnd,
                onMarqueeSelect: { rect in selectObjectsInRect(rect) }
            )
        }
    }

    private func selectObjectsInRect(_ worldRect: CGRect) {
        let ids = viewModel.canvasObjects.filter { obj in
            let objRect = CGRect(
                x: obj.worldPosition.x, y: obj.worldPosition.y,
                width: obj.size.width, height: obj.size.height
            )
            return worldRect.intersects(objRect)
        }.map(\.id)
        if !ids.isEmpty { viewModel.selection.selectObjects(Set(ids)) }
    }

    // MARK: - Tool Mode Hint

    private func toolModeHint(_ text: String) -> some View {
        Text(text)
            .font(Brand.captionFont)
            .foregroundStyle(Brand.inkTertiary)
            .padding(.horizontal, Brand.spacingM)
            .padding(.vertical, Brand.spacingS)
            .background(Capsule().fill(.ultraThinMaterial))
            .allowsHitTesting(false)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, Brand.chromeBottomOffset)
    }

    // MARK: - Empty Canvas Hint

    private var emptyCanvasHint: some View {
        VStack(spacing: Brand.spacingM) {
            Image(systemName: "pencil.and.outline")
                .font(.system(size: 36))
                .foregroundStyle(Brand.inkTertiary)

            Text(String(localized: "canvas.empty.hint"))
                .font(Brand.titleFont)
                .foregroundStyle(Brand.inkTertiary)
                .multilineTextAlignment(.center)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .transition(.opacity)
        .animation(.easeOut(duration: 0.5), value: viewModel.drawing.strokes.isEmpty)
    }
}

#Preview {
    CanvasView()
}

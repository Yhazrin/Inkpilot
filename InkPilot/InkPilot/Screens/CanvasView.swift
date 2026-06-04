import SwiftUI

/// The main canvas screen — InkPilot's core product surface.
struct CanvasView: View {
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
            .onChange(of: viewModel.drawing) { _, _ in
                viewModel.autoSave()
            }

            // 3. Non-interactive motion effects
            CanvasMotionLayer(
                anchor: viewModel.suggestionAnchor.map {
                    viewModel.worldToScreen($0.cgPoint)
                },
                isThinking: viewModel.isThinking,
                hasGhost: viewModel.ghostSuggestion != nil,
                materializationCount: materializationCount
            )

            // 4. Canvas objects
            CanvasObjectLayer(
                objects: viewModel.canvasObjects,
                selectedIDs: viewModel.selection.selectedIDs,
                editingID: viewModel.selection.editingID,
                isSelectToolActive: viewModel.selectedTool == .select,
                isConnectorToolActive: viewModel.selectedTool == .connector,
                connectorStartID: viewModel.connectorStartID,
                sourceAnchor: viewModel.suggestionAnchor?.cgPoint,
                transform: viewModel.canvasTransform,
                onSelect: { viewModel.selection.selectObject($0) },
                onToggleSelection: { viewModel.selection.toggleSelection($0) },
                onGroupTap: { groupID in
                    viewModel.selection.selectGroup(groupID, allObjects: viewModel.canvasObjects)
                },
                onConnectorTap: { viewModel.handleConnectorTap($0) },
                onBeginEditing: { viewModel.selection.beginEditing($0) },
                onEndEditing: { viewModel.selection.endEditing() },
                onTextChange: { id, text in viewModel.updateObjectText(id: id, newText: text) },
                onMove: { id, pos in viewModel.moveObjectWithGuides(id: id, to: pos) },
                onMoveSelected: { delta in viewModel.moveSelectedObjects(by: delta) },
                onDragStart: { viewModel.pushHistoryBeforeMove() },
                onDragEnd: { viewModel.clearGuides() },
                onResize: { id, size in viewModel.resizeObject(id: id, to: size) },
                onResizeStart: { id in viewModel.pushHistoryBeforeResize() }
            )

            // 5. Smart guide lines (visible during drag)
            GuideOverlay(
                guides: viewModel.activeGuides,
                transform: viewModel.canvasTransform
            )

            // 6. Selection layer (marquee or lasso)
            if viewModel.selectedTool == .select {
                if viewModel.useLasso {
                    LassoSelectionLayer(
                        isActive: true,
                        transform: viewModel.canvasTransform,
                        lassoPoints: $viewModel.lassoPoints,
                        onLassoSelect: { _ in
                            viewModel.selectObjectsInLasso(viewModel.lassoPoints)
                        }
                    )
                } else {
                    SelectionMarqueeLayer(
                        isActive: true,
                        transform: viewModel.canvasTransform,
                        marqueeStart: $marqueeStart,
                        marqueeEnd: $marqueeEnd,
                        onMarqueeSelect: { rect in
                            selectObjectsInRect(rect)
                        }
                    )
                }
            }

            // 6. Floating chrome
            floatingChrome
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

    // MARK: - Marquee selection

    private func selectObjectsInRect(_ worldRect: CGRect) {
        let ids = viewModel.canvasObjects.filter { obj in
            let objRect = CGRect(
                x: obj.worldPosition.x,
                y: obj.worldPosition.y,
                width: obj.size.width,
                height: obj.size.height
            )
            return worldRect.intersects(objRect)
        }.map(\.id)
        if !ids.isEmpty {
            viewModel.selection.selectObjects(Set(ids))
        }
    }

    // MARK: - Floating Chrome

    private var floatingChrome: some View {
        VStack {
            VStack(spacing: Brand.spacingS) {
                CanvasToolbar(viewModel: viewModel)

                // Selection mode toggle (marquee vs lasso)
                if viewModel.selectedTool == .select {
                    SelectionModeToggle(useLasso: $viewModel.useLasso)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if viewModel.selectedTool == .pen && viewModel.drawingToolState.isDrawingTool {
                    PenSettingsPalette(drawingState: viewModel.drawingToolState)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

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
                        onMindNode: {
                            let obj = CanvasObjectFactory.mindNode(
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
                        onInsertPlaceholder: { type in
                            let obj: CanvasObject = type == .image
                                ? CanvasObjectFactory.imagePlaceholder(at: viewModel.defaultInsertionPoint)
                                : CanvasObjectFactory.filePlaceholder(at: viewModel.defaultInsertionPoint)
                            viewModel.addObject(obj)
                            viewModel.isMediaPaletteVisible = false
                        },
                        onImportImage: { data, name in
                            viewModel.importImage(data: data, fileName: name)
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
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.selectedTool)

            Spacer()

            VStack(spacing: Brand.spacingS) {
                if viewModel.selection.selectionCount > 1 {
                    MultiObjectActionBar(
                        selectionCount: viewModel.selection.selectionCount,
                        onAlignLeft: { viewModel.alignLeft() },
                        onAlignCenter: { viewModel.alignCenterH() },
                        onAlignRight: { viewModel.alignRight() },
                        onAlignTop: { viewModel.alignTop() },
                        onAlignMiddle: { viewModel.alignMiddleV() },
                        onAlignBottom: { viewModel.alignBottom() },
                        onDistributeH: { viewModel.distributeHorizontal() },
                        onDistributeV: { viewModel.distributeVertical() },
                        onGroup: { viewModel.groupSelected() },
                        onUngroup: { viewModel.ungroupSelected() },
                        onBringToFront: { viewModel.bringToFront() },
                        onSendToBack: { viewModel.sendToBack() },
                        onDelete: { viewModel.deleteSelected() },
                        onDuplicate: { viewModel.duplicateSelected() },
                        onDeselect: { viewModel.selection.clearSelection() }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if viewModel.selection.isSingleSelection {
                    SingleObjectActionBar(
                        onDelete: { viewModel.deleteSelected() },
                        onDuplicate: { viewModel.duplicateSelected() },
                        onBringForward: { viewModel.bringForward() },
                        onSendBackward: { viewModel.sendBackward() },
                        onDeselect: { viewModel.selection.clearSelection() }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                CanvasPromptBar(viewModel: viewModel)
            }
            .padding(.bottom, Brand.spacingL)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.selection.selectionCount)
        }
        .overlay(alignment: .topTrailing) {
            // Export / Share button
            Button {
                if let url = viewModel.exportToShareURL(screenSize: UIScreen.main.bounds.size) {
                    exportURL = url
                    showExportSheet = true
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Brand.inkSecondary)
                    .frame(width: 44, height: 44)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .overlay(Capsule().strokeBorder(Brand.glassBorder, lineWidth: 0.5))
            }
            .padding(.trailing, Brand.spacingM)
            .padding(.top, Brand.spacingM)
            .accessibilityLabel(Text(String(localized: "action.export")))
        }
        .overlay(alignment: .bottomTrailing) {
            AIPilotPanel(viewModel: viewModel)
                .padding(.trailing, Brand.spacingL)
                .padding(.bottom, 100)
        }
        .sheet(isPresented: $showExportSheet) {
            if let exportURL {
                ShareSheet(items: [exportURL])
            }
        }
        .overlay {
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
    }

    private func ghostTarget(for anchor: CGPoint) -> CGPoint {
        CGPoint(x: anchor.x + 220, y: anchor.y + 40)
    }
}

// MARK: - Single Object Action Bar

private struct SingleObjectActionBar: View {
    var onDelete: () -> Void
    var onDuplicate: () -> Void
    var onBringForward: () -> Void
    var onSendBackward: () -> Void
    var onDeselect: () -> Void

    var body: some View {
        GlassCapsule {
            Button(action: onDuplicate) {
                Image(systemName: "plus.square.on.square").frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text(String(localized: "action.duplicate")))

            Button(action: onBringForward) {
                Image(systemName: "arrow.up.to.line").frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text(String(localized: "action.bringForward")))

            Button(action: onSendBackward) {
                Image(systemName: "arrow.down.to.line").frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text(String(localized: "action.sendBackward")))

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

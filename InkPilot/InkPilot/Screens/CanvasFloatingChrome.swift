import SwiftUI

/// The floating chrome layer: toolbar, palettes, action bars, prompt, AI panel.
/// Extracted from CanvasView to keep file sizes manageable.
struct CanvasFloatingChrome: View {
    let viewModel: CanvasViewModel
    @Binding var showExportSheet: Bool
    @Binding var exportURL: URL?

    var body: some View {
        VStack {
            topSection
            Spacer()
            bottomSection
        }
        .overlay(alignment: .topTrailing) {
            exportButton
        }
        .overlay(alignment: .bottomTrailing) {
            AIPilotPanel(viewModel: viewModel)
                .padding(.trailing, Brand.spacingL)
                .padding(.bottom, 100)
        }
    }

    // MARK: - Top Section

    private var topSection: some View {
        VStack(spacing: Brand.spacingS) {
            CanvasToolbar(viewModel: viewModel)

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
                        let obj = CanvasObjectFactory.shape(kind: kind, at: viewModel.defaultInsertionPoint)
                        viewModel.addObject(obj)
                        viewModel.isShapePaletteVisible = false
                    },
                    onMindNode: {
                        let obj = CanvasObjectFactory.mindNode(at: viewModel.defaultInsertionPoint)
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
                    onImportPDF: { url in
                        viewModel.importPDF(from: url)
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
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
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

    // MARK: - Export Buttons

    private var exportButton: some View {
        HStack(spacing: Brand.spacingS) {
            // Export as Image
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
            .accessibilityLabel(Text(String(localized: "action.exportImage")))

            // Export as PDF
            Button {
                if let url = viewModel.exportPDFToShareURL() {
                    exportURL = url
                    showExportSheet = true
                }
            } label: {
                Image(systemName: "doc.richtext")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Brand.inkSecondary)
                    .frame(width: 44, height: 44)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .overlay(Capsule().strokeBorder(Brand.glassBorder, lineWidth: 0.5))
            }
            .accessibilityLabel(Text(String(localized: "action.exportPDF")))
        }
        .padding(.trailing, Brand.spacingM)
        .padding(.top, Brand.spacingM)
        .accessibilityLabel(Text(String(localized: "action.export")))
    }
}

// MARK: - Single Object Action Bar

struct SingleObjectActionBar: View {
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

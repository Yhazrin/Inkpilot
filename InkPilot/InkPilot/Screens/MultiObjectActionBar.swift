import SwiftUI

/// Callbacks for multi-selection actions, reducing parameter count.
struct MultiSelectionActions {
    var onAlignLeft: () -> Void
    var onAlignCenter: () -> Void
    var onAlignRight: () -> Void
    var onAlignTop: () -> Void
    var onAlignMiddle: () -> Void
    var onAlignBottom: () -> Void
    var onDistributeH: () -> Void
    var onDistributeV: () -> Void
    var onGroup: () -> Void
    var onUngroup: () -> Void
    var onBringToFront: () -> Void
    var onSendToBack: () -> Void
    var onDelete: () -> Void
    var onDuplicate: () -> Void
    var onDeselect: () -> Void
}

/// Action bar shown when multiple objects are selected.
/// Provides alignment, distribution, grouping, and layer actions.
struct MultiObjectActionBar: View {
    let selectionCount: Int
    let actions: MultiSelectionActions

    @State private var showAlignment = false

    var body: some View {
        HStack(spacing: Brand.spacingS) {
            // Selection count
            Text(String(format: String(localized: "selection.count"), selectionCount))
                .font(Brand.captionFont)
                .foregroundStyle(Brand.inkSecondary)

            Divider().frame(height: Brand.dividerHeightTall)

            // Quick actions
            actionButton(icon: "plus.square.on.square", label: "action.duplicate", action: actions.onDuplicate)
            actionButton(icon: "trash", label: "action.delete", action: actions.onDelete, tint: .red)

            Divider().frame(height: Brand.dividerHeightTall)

            // Alignment toggle
            Button {
                withAnimation(MotionTokens.alignmentToggle) {
                    showAlignment.toggle()
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .frame(width: Brand.touchTarget, height: Brand.touchTarget)
            }
            .accessibilityLabel(Text(String(localized: "action.alignment")))

            // Group / Ungroup
            actionButton(icon: "rectangle.2.group", label: "action.group", action: actions.onGroup)
            actionButton(icon: "rectangle.2.group.badge.xmark", label: "action.ungroup", action: actions.onUngroup)

            // Layer
            actionButton(icon: "arrow.up.to.line", label: "action.bringToFront", action: actions.onBringToFront)
            actionButton(icon: "arrow.down.to.line", label: "action.sendToBack", action: actions.onSendToBack)

            Divider().frame(height: Brand.dividerHeightTall)

            actionButton(icon: "xmark.circle", label: "action.deselect", action: actions.onDeselect)
        }
        .padding(.horizontal, Brand.spacingS)
        .padding(.vertical, Brand.spacingXS)
        .background {
            Capsule().fill(.ultraThinMaterial)
        }
        .overlay {
            Capsule().strokeBorder(Brand.glassBorder, lineWidth: 0.5)
        }
        .shadow(color: Brand.glassShadow, radius: Brand.shadowRadius, y: Brand.shadowY)
        .overlay(alignment: .top) {
            if showAlignment {
                alignmentPanel
                    .offset(y: Brand.alignmentPanelOffset)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(MotionTokens.alignmentToggle, value: showAlignment)
    }

    // MARK: - Alignment Panel

    private var alignmentPanel: some View {
        GlassCapsule {
            actionButton(icon: "align.horizontal.left", label: "action.alignLeft", action: actions.onAlignLeft)
            actionButton(icon: "align.horizontal.center", label: "action.alignCenter", action: actions.onAlignCenter)
            actionButton(icon: "align.horizontal.right", label: "action.alignRight", action: actions.onAlignRight)
            Divider().frame(height: Brand.dividerHeightTall)
            actionButton(icon: "align.vertical.top", label: "action.alignTop", action: actions.onAlignTop)
            actionButton(icon: "align.vertical.center", label: "action.alignMiddle", action: actions.onAlignMiddle)
            actionButton(icon: "align.vertical.bottom", label: "action.alignBottom", action: actions.onAlignBottom)
            Divider().frame(height: Brand.dividerHeightTall)
            actionButton(icon: "arrow.left.and.right", label: "action.distributeHorizontal", action: actions.onDistributeH)
            actionButton(icon: "arrow.up.and.down", label: "action.distributeVertical", action: actions.onDistributeV)
        }
    }

    // MARK: - Helper

    private func actionButton(icon: String, label: String, action: @escaping () -> Void, tint: Color = Brand.inkPrimary) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(Brand.paletteFont)
                .foregroundStyle(tint)
                .frame(width: Brand.touchTargetSmall, height: Brand.touchTargetSmall)
        }
        .accessibilityLabel(Text(LocalizedStringKey(label)))
    }
}

import SwiftUI

/// Action bar shown when multiple objects are selected.
/// Provides alignment, distribution, grouping, and layer actions.
struct MultiObjectActionBar: View {
    let selectionCount: Int
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

    @State private var showAlignment = false

    var body: some View {
        HStack(spacing: Brand.spacingS) {
            // Selection count
            Text(String(format: String(localized: "selection.count"), selectionCount))
                .font(Brand.captionFont)
                .foregroundStyle(Brand.inkSecondary)

            Divider().frame(height: 24)

            // Quick actions
            actionButton(icon: "plus.square.on.square", label: "action.duplicate", action: onDuplicate)
            actionButton(icon: "trash", label: "action.delete", action: onDelete, tint: .red)

            Divider().frame(height: 24)

            // Alignment toggle
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    showAlignment.toggle()
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .frame(width: Brand.touchTarget, height: Brand.touchTarget)
            }
            .accessibilityLabel(Text(String(localized: "action.alignment")))

            // Group / Ungroup
            actionButton(icon: "rectangle.2.group", label: "action.group", action: onGroup)
            actionButton(icon: "rectangle.2.group.badge.xmark", label: "action.ungroup", action: onUngroup)

            // Layer
            actionButton(icon: "arrow.up.to.line", label: "action.bringToFront", action: onBringToFront)
            actionButton(icon: "arrow.down.to.line", label: "action.sendToBack", action: onSendToBack)

            Divider().frame(height: 24)

            actionButton(icon: "xmark.circle", label: "action.deselect", action: onDeselect)
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
                    .offset(y: -50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: showAlignment)
    }

    // MARK: - Alignment Panel

    private var alignmentPanel: some View {
        GlassCapsule {
            actionButton(icon: "align.horizontal.left", label: "action.alignLeft", action: onAlignLeft)
            actionButton(icon: "align.horizontal.center", label: "action.alignCenter", action: onAlignCenter)
            actionButton(icon: "align.horizontal.right", label: "action.alignRight", action: onAlignRight)
            Divider().frame(height: 24)
            actionButton(icon: "align.vertical.top", label: "action.alignTop", action: onAlignTop)
            actionButton(icon: "align.vertical.center", label: "action.alignMiddle", action: onAlignMiddle)
            actionButton(icon: "align.vertical.bottom", label: "action.alignBottom", action: onAlignBottom)
            Divider().frame(height: 24)
            actionButton(icon: "arrow.left.and.right", label: "action.distributeHorizontal", action: onDistributeH)
            actionButton(icon: "arrow.up.and.down", label: "action.distributeVertical", action: onDistributeV)
        }
    }

    // MARK: - Helper

    private func actionButton(icon: String, label: String, action: @escaping () -> Void, tint: Color = Brand.inkPrimary) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(Brand.paletteFont)
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
        }
        .accessibilityLabel(Text(String(localized: label)))
    }
}

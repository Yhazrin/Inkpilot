import SwiftUI

/// Compact AI Pilot floating panel.
///
/// The collapsed chip and the expanded panel share a
/// `matchedGeometryEffect` group, so they feel like one continuous
/// object morphing rather than two unrelated surfaces switching. The
/// panel's *contents* (dividers, "Canvas Context", suggestion list)
/// fade in only after the surface morph settles, so the morph never
/// gets visually crowded.
struct AIPilotPanel: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var pilotShape

    let viewModel: CanvasViewModel

    var body: some View {
        Button {
            withAnimation(
                MotionTokens.respecting(MotionTokens.morph, reduceMotion: reduceMotion)
            ) {
                viewModel.isAIPanelExpanded.toggle()
            }
        } label: {
            surface
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(String(localized: "canvas.aiPilot.accessibility")))
        .accessibilityHint(Text(String(localized: "canvas.aiPilot.hint")))
        .accessibilityValue(
            viewModel.isAIPanelExpanded
                ? Text(String(localized: "canvas.aiPilot.expanded"))
                : Text(String(localized: "canvas.aiPilot.collapsed"))
        )
    }

    // MARK: - Surface (chip ↔ panel)

    @ViewBuilder
    private var surface: some View {
        if viewModel.isAIPanelExpanded {
            expandedPanel
                .matchedGeometryEffect(id: "pilotShape", in: pilotShape)
        } else {
            collapsedChip
                .matchedGeometryEffect(id: "pilotShape", in: pilotShape)
        }
    }

    // MARK: - Collapsed (chip)

    private var collapsedChip: some View {
        HStack(spacing: Brand.spacingS) {
            AIBadge()
            Text(String(localized: "canvas.aiPilot.title"))
                .font(Brand.captionFont)
                .foregroundStyle(Brand.inkSecondary)
        }
        .padding(.horizontal, Brand.spacingM)
        .padding(.vertical, Brand.spacingS)
        .background {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(Brand.glassBorder, lineWidth: 0.5)
        }
        .shadow(color: Brand.glassShadow, radius: Brand.shadowRadius, y: Brand.shadowY)
    }

    // MARK: - Expanded (panel)

    private var expandedPanel: some View {
        VStack(alignment: .leading, spacing: Brand.spacingS) {
            header
            expandedContent
                .transition(.opacity)
        }
        .padding(Brand.spacingM)
        .frame(width: 260)
        .background {
            RoundedRectangle(cornerRadius: Brand.cornerL, style: .continuous)
                .fill(.regularMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Brand.cornerL, style: .continuous)
                .strokeBorder(Brand.glassBorder, lineWidth: 0.5)
        }
        .shadow(color: Brand.glassShadow, radius: Brand.shadowRadius, y: Brand.shadowY)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "canvas.aiPilot.title"))
                    .font(Brand.titleFont)
                    .foregroundStyle(Brand.inkPrimary)

                Text(String(localized: "canvas.aiPilot.suggestions"))
                    .font(Brand.captionFont)
                    .foregroundStyle(Brand.inkSecondary)
            }

            Spacer()

            Image(systemName: "chevron.down")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Brand.inkSecondary)
        }
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: Brand.spacingS) {
            Divider()

            Text(String(localized: "canvas.aiPilot.context"))
                .font(Brand.captionFont)
                .foregroundStyle(Brand.inkSecondary)

            Text(String(localized: "canvas.aiPilot.contextValue"))
                .font(Brand.bodyFont)
                .foregroundStyle(Brand.inkPrimary)

            Divider()

            Text(String(localized: "canvas.aiPilot.suggestionsList"))
                .font(Brand.captionFont)
                .foregroundStyle(Brand.inkSecondary)

            suggestionRow(String(localized: "canvas.aiPilot.suggestion1"))
            suggestionRow(String(localized: "canvas.aiPilot.suggestion2"))
            suggestionRow(String(localized: "canvas.aiPilot.suggestion3"))
        }
    }

    private func suggestionRow(_ text: String) -> some View {
        HStack(spacing: Brand.spacingS) {
            Circle()
                .fill(Brand.aiBadge.opacity(0.3))
                .frame(width: 6, height: 6)
            Text(text)
                .font(Brand.bodyFont)
                .foregroundStyle(Brand.inkPrimary)
        }
    }
}

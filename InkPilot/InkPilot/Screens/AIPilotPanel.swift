import SwiftUI

/// Compact AI Pilot floating panel.
/// Collapsed state: a small status chip (just a sparkle + count).
/// Expanded state: a spatial panel with a soft header, divider, and
/// list of suggested next steps. Avoids the "generic white card" feel
/// by leaving generous whitespace and using the muted typography.
struct AIPilotPanel: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let viewModel: CanvasViewModel

    var body: some View {
        Button {
            withAnimation(Motion.respecting(Motion.standard, reduceMotion: reduceMotion)) {
                viewModel.isAIPanelExpanded.toggle()
            }
        } label: {
            content
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

    @ViewBuilder
    private var content: some View {
        if viewModel.isAIPanelExpanded {
            expandedPanel
        } else {
            collapsedChip
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
            Capsule()
                .fill(.ultraThinMaterial)
        }
        .overlay {
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [Brand.glassHighlight, Brand.glassBorder],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: Brand.hairline
                )
        }
        .shadow(
            color: Brand.glassShadow,
            radius: Brand.shadowRadius,
            y: Brand.shadowY
        )
    }

    // MARK: - Expanded (panel)

    private var expandedPanel: some View {
        VStack(alignment: .leading, spacing: Brand.spacingM) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "canvas.aiPilot.title"))
                        .font(Brand.titleFont)
                        .foregroundStyle(Brand.inkPrimary)

                    Text(String(localized: "canvas.aiPilot.suggestions"))
                        .font(Brand.microFont)
                        .foregroundStyle(Brand.inkSecondary)
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Brand.inkSecondary)
            }

            Divider()
                .overlay(Brand.glassBorder)

            VStack(alignment: .leading, spacing: Brand.spacingS) {
                Text(String(localized: "canvas.aiPilot.context"))
                    .font(Brand.microFont)
                    .foregroundStyle(Brand.inkSecondary)
                    .textCase(.uppercase)

                Text(String(localized: "canvas.aiPilot.contextValue"))
                    .font(Brand.bodyFont)
                    .foregroundStyle(Brand.inkPrimary)
            }

            Divider()
                .overlay(Brand.glassBorder)

            VStack(alignment: .leading, spacing: Brand.spacingS) {
                Text(String(localized: "canvas.aiPilot.suggestionsList"))
                    .font(Brand.microFont)
                    .foregroundStyle(Brand.inkSecondary)
                    .textCase(.uppercase)

                suggestionRow(String(localized: "canvas.aiPilot.suggestion1"))
                suggestionRow(String(localized: "canvas.aiPilot.suggestion2"))
                suggestionRow(String(localized: "canvas.aiPilot.suggestion3"))
            }
        }
        .padding(Brand.spacingM)
        .frame(width: 260)
        .background {
            RoundedRectangle(cornerRadius: Brand.cornerL, style: .continuous)
                .fill(.regularMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Brand.cornerL, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Brand.glassHighlight, Brand.glassBorder],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: Brand.hairline
                )
        }
        .shadow(
            color: Brand.glassShadow,
            radius: Brand.shadowRadius,
            y: Brand.shadowY
        )
    }

    private func suggestionRow(_ text: String) -> some View {
        HStack(spacing: Brand.spacingS) {
            Circle()
                .fill(Brand.aiMark)
                .frame(width: 4, height: 4)
            Text(text)
                .font(Brand.bodyFont)
                .foregroundStyle(Brand.inkPrimary)
        }
    }
}

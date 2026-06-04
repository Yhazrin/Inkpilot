import SwiftUI

/// Compact AI Pilot floating panel.
/// Shows canvas context and mock suggestions in a collapsible glass panel.
struct AIPilotPanel: View {
    let viewModel: CanvasViewModel

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                viewModel.isAIPanelExpanded.toggle()
            }
        } label: {
            FloatingPanel {
                header
                if viewModel.isAIPanelExpanded {
                    expandedContent
                }
            }
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

    // MARK: - Header

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

            Image(systemName: viewModel.isAIPanelExpanded ? "chevron.down" : "chevron.left")
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
                .fill(Brand.aiAccent.opacity(0.3))
                .frame(width: 6, height: 6)
            Text(text)
                .font(Brand.bodyFont)
                .foregroundStyle(Brand.inkPrimary)
        }
    }
}

import SwiftUI

/// A semi-transparent ghost card showing an AI suggestion.
/// Appears near recent handwriting with Accept / Dismiss actions.
struct GhostSuggestionCard: View {
    let suggestion: GhostSuggestion
    var onAccept: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerM) {
            VStack(alignment: .leading, spacing: Brand.spacingM) {
                header
                itemsList
                actionButtons
            }
        }
        .opacity(0.85)
        .overlay {
            RoundedRectangle(cornerRadius: Brand.cornerM, style: .continuous)
                .strokeBorder(Brand.aiGlow, lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(String(localized: "ghost.accessibility")))
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: Brand.spacingS) {
            AIBadge()
            Text(suggestion.response.title)
                .font(Brand.titleFont)
                .foregroundStyle(Brand.inkPrimary)
        }
    }

    // MARK: - Items List

    private var itemsList: some View {
        VStack(alignment: .leading, spacing: Brand.spacingS) {
            ForEach(suggestion.response.items) { item in
                HStack(alignment: .top, spacing: Brand.spacingS) {
                    Circle()
                        .fill(Brand.aiBadge.opacity(0.3))
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(Brand.bodyFont.weight(.semibold))
                            .foregroundStyle(Brand.inkPrimary)
                        Text(item.content)
                            .font(Brand.captionFont)
                            .foregroundStyle(Brand.inkSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: Brand.spacingM) {
            Button(action: onAccept) {
                Label(
                    String(localized: "suggestion.accept"),
                    systemImage: "checkmark.circle.fill"
                )
                .font(Brand.bodyFont.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, Brand.spacingM)
                .padding(.vertical, Brand.spacingS)
                .background {
                    Capsule()
                        .fill(Brand.aiBadge)
                }
            }
            .accessibilityLabel(Text(String(localized: "suggestion.accept.accessibility")))
            .accessibilityHint(Text(String(localized: "suggestion.accept.hint")))

            Button(action: onDismiss) {
                Label(
                    String(localized: "suggestion.dismiss"),
                    systemImage: "xmark.circle"
                )
                .font(Brand.bodyFont.weight(.medium))
                .foregroundStyle(Brand.inkSecondary)
                .padding(.horizontal, Brand.spacingM)
                .padding(.vertical, Brand.spacingS)
                .background {
                    Capsule()
                        .strokeBorder(Brand.glassBorder, lineWidth: 0.5)
                }
            }
            .accessibilityLabel(Text(String(localized: "suggestion.dismiss.accessibility")))
            .accessibilityHint(Text(String(localized: "suggestion.dismiss.hint")))
        }
        .padding(.top, Brand.spacingXS)
    }
}

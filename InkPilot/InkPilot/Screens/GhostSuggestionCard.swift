import SwiftUI

/// A semi-transparent ghost card showing an AI suggestion.
/// Appears with a calm fade + scale + soft blur in, and removes
/// with a gentle fade. Uses the muted AIBadge and a subtle
/// hairline so it doesn't feel like a hard pop-up.
struct GhostSuggestionCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let suggestion: GhostSuggestion
    var onAccept: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacingM) {
            header
            itemsList
            actionButtons
        }
        .padding(Brand.spacingL)
        .background {
            RoundedRectangle(cornerRadius: Brand.cornerM, style: .continuous)
                .fill(.regularMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Brand.cornerM, style: .continuous)
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
                        .fill(Brand.aiMark)
                        .frame(width: 4, height: 4)
                        .padding(.top, 7)

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
                Text(String(localized: "suggestion.accept"))
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
                Text(String(localized: "suggestion.dismiss"))
                    .font(Brand.bodyFont.weight(.medium))
                    .foregroundStyle(Brand.inkSecondary)
                    .padding(.horizontal, Brand.spacingM)
                    .padding(.vertical, Brand.spacingS)
                    .background {
                        Capsule()
                            .strokeBorder(Brand.glassBorder, lineWidth: Brand.hairline)
                    }
            }
            .accessibilityLabel(Text(String(localized: "suggestion.dismiss.accessibility")))
            .accessibilityHint(Text(String(localized: "suggestion.dismiss.hint")))
        }
        .padding(.top, Brand.spacingXS)
    }
}

// MARK: - Transition

extension AnyTransition {
    /// Calm, premium feel: a touch of scale + fade + a soft blur pass.
    /// Used for the ghost suggestion card appearing on the canvas.
    static var ghostAppear: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: GhostAppearModifier(progress: 0),
                identity: GhostAppearModifier(progress: 1)
            ),
            removal: .opacity.combined(with: .scale(scale: 0.96))
        )
    }
}

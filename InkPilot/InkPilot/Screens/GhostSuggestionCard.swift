import SwiftUI

/// A semi-transparent ghost card showing an AI suggestion.
///
/// Rather than a centered popover, this card *emerges from* the
/// `suggestionAnchor` — the canvas-space point that "birthed" the
/// suggestion. The card is offset from the anchor toward a calmer
/// position so it doesn't sit on top of the ink, but it visibly
/// travels from there on appearance.
struct GhostSuggestionCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let suggestion: GhostSuggestion
    /// Canvas-space point the card should appear from.
    let anchor: CGPoint
    /// Final position of the card (in canvas coordinates).
    let target: CGPoint
    var onAccept: () -> Void
    var onDismiss: () -> Void

    /// Vector the card travels during the emerge animation.
    /// Sign: from `target` back to `anchor`. We invert it at use sites
    /// so the modifier expects "how far to be from origin at progress 0".
    private var travel: CGSize {
        CGSize(
            width: anchor.x - target.x,
            height: anchor.y - target.y
        )
    }

    var body: some View {
        GhostCardBody(
            suggestion: suggestion,
            onAccept: onAccept,
            onDismiss: onDismiss
        )
        .frame(maxWidth: 380)
        .position(target)
        .modifier(GhostEmergeModifier(
            progress: reduceMotion ? 1 : 1,
            travel: travel
        ))
        .animation(
            SemanticMotion.respecting(SemanticMotion.emerge, reduceMotion: reduceMotion),
            value: suggestion.id
        )
    }
}

/// The visible card body, extracted so the emerge modifier only wraps
/// the *positioned* card (not its internal layout).
private struct GhostCardBody: View {
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
        .opacity(0.92)
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

import SwiftUI

/// A semi-transparent ghost card showing an AI suggestion.
///
/// The card *emerges from* the `anchor` — the canvas-space point that
/// "birthed" the suggestion — and lands at `target`, which is offset
/// from the anchor so the card does not sit on top of the ink.
///
/// Emerge is driven by real `@State` (`appearProgress`) that animates
/// from 0 to 1 inside `withAnimation(MotionTokens.emerge)`. The view's
/// body reads this state, so SwiftUI produces a real interpolated
/// view tree at every frame: at 0 the card is hidden at the source
/// (opacity 0, scale 0.86, blur 6, offset toward anchor); at 1 the
/// card rests at `target` with full opacity, scale, and no blur.
struct GhostSuggestionCard: View {
    let suggestion: GhostSuggestion
    /// Canvas-space point the card was born from.
    let anchor: CGPoint
    /// Final canvas-space position of the card.
    let target: CGPoint
    var onAccept: () -> Void
    var onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Emerge progress: 0 = hidden at source, 1 = fully arrived at
    /// target. Driven by `.onAppear` with `withAnimation`.
    @State private var appearProgress: CGFloat = 0

    /// Travel vector: from final position back to the source. Used to
    /// offset the card toward the anchor while it is still emerging.
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
        .frame(maxWidth: 360)
        .fixedSize(horizontal: false, vertical: true)
        .scaleEffect(0.86 + 0.14 * Double(appearProgress))
        .opacity(0.92 * Double(appearProgress))
        .blur(radius: (1 - Double(appearProgress)) * 6)
        .offset(
            x: (1 - Double(appearProgress)) * travel.width * 0.4,
            y: (1 - Double(appearProgress)) * travel.height * 0.4
        )
        .position(target)
        .onAppear {
            // Drive the emerge. Under Reduce Motion the helper returns
            // a near-instant animation, so the card still appears —
            // it just skips the spring interpolation.
            withAnimation(
                MotionTokens.respecting(MotionTokens.emerge, reduceMotion: reduceMotion)
            ) {
                appearProgress = 1
            }
        }
    }
}

/// The visible card body, extracted so the emerge modifier only wraps
/// the positioned card.
private struct GhostCardBody: View {
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
                .fill(Brand.canvasBase.opacity(0.85))
        }
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
                .lineLimit(1)
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
                            .fixedSize(horizontal: false, vertical: true)
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

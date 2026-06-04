import SwiftUI

/// Renders accepted AI suggestion cards as flat canvas objects.
///
/// Each card *materializes from* the `sourceAnchor` and settles into
/// its `worldPosition` with a per-card stagger. The transition uses
/// real `active`/`identity` endpoints with different body outputs, so
/// SwiftUI interpolates from "hidden at the source" to "rested at the
/// world position" — not a fake wrapper around a hard-coded progress.
struct AcceptedCardsOverlay: View {
    let cards: [AcceptedCard]
    /// Canvas-space point the cards traveled from. When nil (cold
    /// start, no recent ghost), cards have no travel — they just
    /// appear at their `worldPosition`.
    let sourceAnchor: CGPoint?

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                AcceptedCardView(card: card)
                    .frame(
                        width: card.size.cgSize.width,
                        height: card.size.cgSize.height
                    )
                    .position(card.worldPosition.cgPoint)
                    .transition(
                        .asymmetric(
                            insertion: .modifier(
                                active: MaterializeModifier(
                                    progress: 0,
                                    travel: travelVector(for: card)
                                ),
                                identity: MaterializeModifier(
                                    progress: 1,
                                    travel: travelVector(for: card)
                                )
                            ),
                            removal: .opacity
                        )
                    )
                    .animation(
                        MotionTokens.respecting(
                            MotionTokens.materialize
                                .delay(Double(index) * MotionTokens.cardStagger),
                            reduceMotion: false
                        ),
                        value: card.id
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Travel vector: from world position back to the source. The
    /// materialize modifier uses this to offset the card toward the
    /// source in its `active` state.
    private func travelVector(for card: AcceptedCard) -> CGSize {
        guard let source = sourceAnchor else { return .zero }
        return CGSize(
            width: source.x - card.worldPosition.cgPoint.x,
            height: source.y - card.worldPosition.cgPoint.y
        )
    }
}

// MARK: - Single card

/// A single accepted card, drawn as a flat translucent panel — closer
/// to a sticky note than a glass dashboard tile.
private struct AcceptedCardView: View {
    let card: AcceptedCard

    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacingS) {
            HStack(alignment: .firstTextBaseline, spacing: Brand.spacingS) {
                Text(card.title)
                    .font(Brand.titleFont)
                    .foregroundStyle(Brand.inkPrimary)
                    .lineLimit(1)
                Spacer(minLength: 0)
                CanvasProvenanceMark()
            }

            Text(card.body)
                .font(Brand.bodyFont)
                .foregroundStyle(Brand.inkSecondary)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Brand.spacingM)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: Brand.cornerM, style: .continuous)
                .fill(Brand.canvasBase.opacity(0.85))
        }
        .overlay {
            RoundedRectangle(cornerRadius: Brand.cornerM, style: .continuous)
                .strokeBorder(Brand.glassBorder, lineWidth: 0.5)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(String(localized: "acceptedCard.accessibility")))
    }
}

// MARK: - Provenance

/// A quiet dot for "this came from AI" — replaces the bright AI pill
/// badge on canvas objects. Sits in the top-trailing corner of an
/// accepted card. Keeps the a11y label from `AIBadge`.
struct CanvasProvenanceMark: View {
    var body: some View {
        Circle()
            .fill(Brand.aiBadge.opacity(0.45))
            .frame(width: 6, height: 6)
            .accessibilityLabel(Text(String(localized: "badge.ai.generated")))
    }
}

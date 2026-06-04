import SwiftUI

/// Renders accepted AI suggestion cards as flat canvas objects.
///
/// Each card *materializes* from the `sourceAnchor` (the canvas point
/// the ghost was born from) and settles into its `worldPosition` with
/// a per-card stagger. The visual treatment is intentionally flatter
/// than `GlassCard`: a hairline-bordered translucent surface that reads
/// as a sticky note on the page, not a glass dashboard tile.
struct AcceptedCardsOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let cards: [AcceptedCard]
    /// Canvas-space point the cards traveled from. When nil (e.g. on
    /// cold start) each card uses its own `worldPosition` as both
    /// source and target — no travel, just appear.
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
                    .modifier(MaterializeModifier(
                        progress: reduceMotion ? 1 : 1,
                        travel: travelVector(for: card)
                    ))
                    .animation(
                        SemanticMotion.respecting(
                            SemanticMotion.materialize
                                .delay(reduceMotion ? 0 : Double(index) * SemanticMotion.cardStagger),
                            reduceMotion: reduceMotion
                        ),
                        value: card.id
                    )
                    .transition(reduceMotion ? .opacity : .opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func travelVector(for card: AcceptedCard) -> CGSize {
        guard let source = sourceAnchor else {
            return .zero
        }
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
                // Flatter than GlassCard: no material, no shadow —
                // a soft tinted fill so cards sit on the page.
                .fill(Brand.canvasBase.opacity(0.72))
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

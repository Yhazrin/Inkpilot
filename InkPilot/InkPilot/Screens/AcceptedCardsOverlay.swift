import SwiftUI

/// Renders accepted AI suggestion cards as floating glass cards on the canvas.
/// Each card is placed at its `worldPosition` with its `size`, both authored by
/// the view model when the suggestion was accepted.
struct AcceptedCardsOverlay: View {
    let cards: [AcceptedCard]

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(cards) { card in
                AcceptedCardView(card: card)
                    .frame(
                        width: card.size.cgSize.width,
                        height: card.size.cgSize.height
                    )
                    .position(card.worldPosition.cgPoint)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: cards.count)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A single accepted card rendered as a glass card with AI badge.
private struct AcceptedCardView: View {
    let card: AcceptedCard

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerM) {
            VStack(alignment: .leading, spacing: Brand.spacingS) {
                HStack(spacing: Brand.spacingS) {
                    Text(card.title)
                        .font(Brand.titleFont)
                        .foregroundStyle(Brand.inkPrimary)
                    AIBadge()
                }

                Text(card.body)
                    .font(Brand.bodyFont)
                    .foregroundStyle(Brand.inkSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(String(localized: "acceptedCard.accessibility")))
    }
}

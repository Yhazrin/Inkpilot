import SwiftUI

/// Renders accepted AI suggestion cards as floating glass cards on the canvas.
/// Cards are laid out in a vertical stack at the center-right area.
struct AcceptedCardsOverlay: View {
    let cards: [AcceptedCard]

    var body: some View {
        VStack(alignment: .leading, spacing: Brand.spacingM) {
            ForEach(cards) { card in
                AcceptedCardView(card: card)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: cards.count)
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
        .frame(maxWidth: 300)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(String(localized: "acceptedCard.accessibility")))
    }
}

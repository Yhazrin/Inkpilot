import SwiftUI

/// Renders accepted AI suggestion cards as floating glass cards on the canvas.
/// Each card is placed at its `worldPosition` with its `size`, both authored
/// by the view model when the suggestion was accepted. Cards stagger in
/// with a calm settle when added (respecting Reduce Motion).
struct AcceptedCardsOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let cards: [AcceptedCard]

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                AcceptedCardView(card: card)
                    .frame(
                        width: card.size.cgSize.width,
                        height: card.size.cgSize.height
                    )
                    .position(card.worldPosition.cgPoint)
                    .transition(cardTransition)
                    .animation(
                        Motion.respecting(
                            Motion.settle.delay(reduceMotion ? 0 : Double(index) * Motion.cardStagger),
                            reduceMotion: reduceMotion
                        ),
                        value: card.id
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var cardTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }
        return .asymmetric(
            insertion: .modifier(
                active: CardSettleModifier(progress: 0),
                identity: CardSettleModifier(progress: 1)
            ),
            removal: .opacity
        )
    }
}

/// A single accepted card rendered as a glass card with a quiet AI mark.
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
                AIBadge()
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
            color: Brand.glassShadowSoft,
            radius: 24,
            y: 8
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(String(localized: "acceptedCard.accessibility")))
    }
}

// MARK: - Settle modifier (defined in MotionTokens.swift)

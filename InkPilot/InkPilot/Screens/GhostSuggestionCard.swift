import SwiftUI

/// A semi-transparent ghost card that emerges from the suggestion
/// anchor and lands at a target position offset from the ink.
struct GhostSuggestionCard: View {
    let suggestion: GhostSuggestion
    let anchor: CGPoint
    let target: CGPoint
    var onAccept: () -> Void
    var onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appearProgress: CGFloat = 0

    private var travel: CGSize {
        CGSize(width: anchor.x - target.x, height: anchor.y - target.y)
    }

    var body: some View {
        cardBody
            .frame(maxWidth: Brand.ghostCardMaxWidth)
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
                withAnimation(
                    MotionTokens.respecting(MotionTokens.emerge, reduceMotion: reduceMotion)
                ) {
                    appearProgress = 1
                }
            }
    }

    // MARK: - Card Body

    private var cardBody: some View {
        GlassCard(cornerRadius: Brand.cornerM) {
            VStack(alignment: .leading, spacing: Brand.spacingM) {
                header
                itemsList
                actionButtons
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: Brand.cornerM, style: .continuous)
                .strokeBorder(Brand.aiHalo, lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(String(localized: "ghost.accessibility")))
    }

    private var header: some View {
        HStack(spacing: Brand.spacingS) {
            AIBadge()
            Text(suggestion.response.title)
                .font(Brand.titleFont)
                .foregroundStyle(Brand.inkPrimary)
        }
    }

    private var itemsList: some View {
        VStack(alignment: .leading, spacing: Brand.spacingS) {
            ForEach(suggestion.response.items) { item in
                HStack(alignment: .top, spacing: Brand.spacingS) {
                    Circle()
                        .fill(Brand.aiAccent.opacity(Brand.aiAccentBulletOpacity))
                        .frame(width: Brand.bulletSize, height: Brand.bulletSize)
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

    private var actionButtons: some View {
        HStack(spacing: Brand.spacingM) {
            Button(action: onAccept) {
                Label(String(localized: "suggestion.accept"), systemImage: "checkmark.circle.fill")
                    .font(Brand.bodyFont.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, Brand.spacingM)
                    .padding(.vertical, Brand.spacingS)
                    .background { Capsule().fill(Brand.aiAccent) }
            }
            .accessibilityLabel(Text(String(localized: "suggestion.accept.accessibility")))
            .accessibilityHint(Text(String(localized: "suggestion.accept.hint")))

            Button(action: onDismiss) {
                Label(String(localized: "suggestion.dismiss"), systemImage: "xmark.circle")
                    .font(Brand.bodyFont.weight(.medium))
                    .foregroundStyle(Brand.inkSecondary)
                    .padding(.horizontal, Brand.spacingM)
                    .padding(.vertical, Brand.spacingS)
                    .background { Capsule().strokeBorder(Brand.glassBorder, lineWidth: Brand.glassBorderWidth) }
            }
            .accessibilityLabel(Text(String(localized: "suggestion.dismiss.accessibility")))
            .accessibilityHint(Text(String(localized: "suggestion.dismiss.hint")))
        }
        .padding(.top, Brand.spacingXS)
    }
}

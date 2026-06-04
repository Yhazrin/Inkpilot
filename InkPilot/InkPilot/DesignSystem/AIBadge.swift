import SwiftUI

/// A quiet AI mark — a tiny gradient dot with a faint sparkle.
/// Replaces the previous loud "AI" pill badge. The accessibility label
/// still announces "AI generated" so VoiceOver behavior is preserved.
struct AIBadge: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Brand.aiMark,
                            Brand.aiMark.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 6
                    )
                )
                .frame(width: 14, height: 14)

            Image(systemName: "sparkle")
                .font(.system(size: 7, weight: .semibold))
                .foregroundStyle(Brand.aiBadge)
        }
        .frame(width: 14, height: 14)
        .accessibilityLabel(Text(String(localized: "badge.ai.generated")))
    }
}

#Preview {
    HStack(spacing: 16) {
        AIBadge()
        AIBadge()
    }
    .padding(20)
    .background(Brand.canvasBase)
}

import SwiftUI

/// A small "AI" badge pill that marks AI-generated or AI-suggested content.
/// Solid black pill with white "AI" text — the Codex/OpenAI accent.
struct AIBadge: View {
    var body: some View {
        Text(String(localized: "badge.ai.text"))
            .font(.system(size: Brand.aiBadgeFontSize, weight: .bold, design: .rounded))
            .foregroundStyle(Brand.inkInverse)
            .padding(.horizontal, Brand.aiBadgePaddingH)
            .padding(.vertical, Brand.aiBadgePaddingV)
            .background {
                Capsule()
                    .fill(Brand.aiAccent)
            }
            .accessibilityLabel(Text(String(localized: "badge.ai.generated")))
    }
}

#Preview {
    AIBadge()
        .padding(Brand.spacingL)
        .background(Brand.canvasBase)
}

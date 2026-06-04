import SwiftUI

/// A small "AI" badge pill that marks AI-generated or AI-suggested content.
/// Solid black pill with white "AI" text — the Codex/OpenAI accent.
struct AIBadge: View {
    var body: some View {
        Text("AI")
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(Brand.inkInverse)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background {
                Capsule()
                    .fill(Brand.aiAccent)
            }
            .accessibilityLabel(Text(String(localized: "badge.ai.generated")))
    }
}

#Preview {
    AIBadge()
        .padding(20)
        .background(Brand.canvasBase)
}

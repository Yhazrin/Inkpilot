import SwiftUI

/// A small "AI" badge pill that marks AI-generated or AI-suggested content.
struct AIBadge: View {
    var body: some View {
        Text("AI")
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background {
                Capsule()
                    .fill(Brand.aiBadge)
            }
            .accessibilityLabel(Text(String(localized: "badge.ai.generated")))
    }
}

#Preview {
    AIBadge()
        .padding(20)
        .background(Brand.canvasBase)
}

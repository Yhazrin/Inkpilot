import SwiftUI

// MARK: - Editable Text Box

struct EditableTextObjectView: View {
    let text: String
    let isEditing: Bool
    var onChange: ((String) -> Void)?
    var onEndEditing: (() -> Void)?

    @State private var editText: String = ""

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerS) {
            if isEditing {
                TextEditor(text: $editText)
                    .font(Brand.bodyFont)
                    .foregroundStyle(Brand.inkPrimary)
                    .scrollContentBackground(.hidden)
                    .onAppear { editText = text }
                    .onChange(of: editText) { _, newValue in
                        onChange?(newValue)
                    }
            } else {
                Text(text.isEmpty ? String(localized: "object.text.placeholder") : text)
                    .font(Brand.bodyFont)
                    .foregroundStyle(text.isEmpty ? Brand.inkSecondary : Brand.inkPrimary)
            }
        }
        .accessibilityLabel(Text(String(localized: "object.textBox.accessibility")))
    }
}

// MARK: - Editable Sticky Note

struct EditableStickyNoteView: View {
    let noteText: String
    let tint: String?
    let isEditing: Bool
    var onChange: ((String) -> Void)?
    var onEndEditing: (() -> Void)?

    @State private var editText: String = ""

    var body: some View {
        RoundedRectangle(cornerRadius: Brand.cornerS, style: .continuous)
            .fill(stickyColor)
            .overlay {
                if isEditing {
                    TextEditor(text: $editText)
                        .font(Brand.captionFont)
                        .foregroundStyle(Brand.inkPrimary)
                        .scrollContentBackground(.hidden)
                        .padding(Brand.spacingS)
                        .onAppear { editText = noteText }
                        .onChange(of: editText) { _, newValue in
                            onChange?(newValue)
                        }
                } else {
                    Text(noteText)
                        .font(Brand.captionFont)
                        .foregroundStyle(Brand.inkPrimary)
                        .padding(Brand.spacingS)
                }
            }
            .shadow(color: Brand.glassShadow, radius: 6, y: 2)
            .accessibilityLabel(Text(String(localized: "object.stickyNote.accessibility")))
    }

    private var stickyColor: Color {
        switch tint {
        case "stickyPink": return Color.pink.opacity(0.2)
        case "stickyGreen": return Color.green.opacity(0.2)
        default: return Color.yellow.opacity(0.25)
        }
    }
}

// MARK: - Editable Bubble

struct EditableBubbleView: View {
    let bubbleText: String
    let isEditing: Bool
    var onChange: ((String) -> Void)?
    var onEndEditing: (() -> Void)?

    @State private var editText: String = ""

    var body: some View {
        GlassCard(cornerRadius: Brand.cornerL) {
            if isEditing {
                TextEditor(text: $editText)
                    .font(Brand.titleFont)
                    .foregroundStyle(Brand.inkPrimary)
                    .scrollContentBackground(.hidden)
                    .multilineTextAlignment(.center)
                    .onAppear { editText = bubbleText }
                    .onChange(of: editText) { _, newValue in
                        onChange?(newValue)
                    }
            } else {
                Text(bubbleText)
                    .font(Brand.titleFont)
                    .foregroundStyle(Brand.inkPrimary)
                    .frame(maxWidth: .infinity)
            }
        }
        .clipShape(Ellipse())
        .accessibilityLabel(Text(String(localized: "object.bubble.accessibility")))
    }
}

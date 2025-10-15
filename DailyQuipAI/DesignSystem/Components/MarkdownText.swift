//
//  MarkdownText.swift
//  DailyQuipAI
//
//  Rich text rendering for Markdown content
//

import SwiftUI

/// A view that renders Markdown text as rich formatted text using SwiftUI's native Text Markdown support
struct MarkdownText: View {
    let markdown: String
    let fontSize: CGFloat
    let lineSpacing: CGFloat

    init(_ markdown: String, fontSize: CGFloat = 16, lineSpacing: CGFloat = 6) {
        self.markdown = markdown
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
    }

    var body: some View {
        // SwiftUI Text natively supports Markdown in iOS 15+
        // Just pass the LocalizedStringKey initializer
        Text(.init(markdown))
            .font(.system(size: fontSize, weight: .regular, design: .rounded))
            .foregroundColor(.primary.opacity(0.9))
            .lineSpacing(lineSpacing)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
    }
}

/// Enhanced Markdown text view - uses SwiftUI's native Markdown rendering
/// This is actually the same as MarkdownText but kept for backward compatibility
struct EnhancedMarkdownText: View {
    let markdown: String
    let fontSize: CGFloat
    let lineSpacing: CGFloat

    init(_ markdown: String, fontSize: CGFloat = 16, lineSpacing: CGFloat = 6) {
        self.markdown = markdown
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
    }

    var body: some View {
        // SwiftUI's Text view automatically handles Markdown formatting
        // Including bold (**), italic (*), code (`), headers (##), etc.
        Text(.init(markdown))
            .font(.system(size: fontSize, weight: .regular, design: .rounded))
            .foregroundColor(.primary.opacity(0.9))
            .lineSpacing(lineSpacing)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
    }
}

#if DEBUG
struct MarkdownTextPreviews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 20) {
            MarkdownText(
                """
                This is **bold** text and this is *italic* text.

                Here's some `code` inline.

                # Heading 1
                ## Heading 2
                ### Heading 3

                Regular paragraph with some content.
                """,
                fontSize: 16
            )
            .padding()

            EnhancedMarkdownText(
                """
                **Enhanced Version**

                This demonstrates *italic*, **bold**, and `code` formatting.

                ## Section Title

                Multiple paragraphs with proper spacing and styling.
                """,
                fontSize: 16
            )
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif

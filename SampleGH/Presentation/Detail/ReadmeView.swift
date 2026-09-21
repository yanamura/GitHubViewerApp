//
//  ReadmeView.swift
//  SampleGH
//

import SwiftUI

struct ReadmeView: View {
  let blocks: [ReadmeBlock]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      ForEach(blocks) { block in
        ReadmeBlockView(kind: block.kind)
      }
    }
  }
}

private struct ReadmeBlockView: View {
  let kind: ReadmeBlock.Kind

  var body: some View {
    switch kind {
    case .heading(let level, let text):
      Text(Self.attributedText(text))
        .font(Self.font(forHeadingLevel: level))
        .bold()
    case .codeBlock(let code):
      Text(code)
        .font(.system(.callout, design: .monospaced))
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    case .paragraph(let text):
      Text(Self.attributedText(text))
        .font(.body)
    }
  }

  private static func font(forHeadingLevel level: Int) -> Font {
    switch level {
    case 1: return .title
    case 2: return .title2
    case 3: return .title3
    default: return .headline
    }
  }

  private static func attributedText(_ text: String) -> AttributedString {
    let options = AttributedString.MarkdownParsingOptions(
      interpretedSyntax: .inlineOnlyPreservingWhitespace)
    return (try? AttributedString(markdown: text, options: options)) ?? AttributedString(text)
  }
}

#Preview {
  ScrollView {
    ReadmeView(
      blocks: ReadmeBlock.parse(
        """
        # Sample Repository

        This is a **sample** readme with _inline_ styling.

        ## Usage

        ```
        let value = 1
        ```
        """)
    )
    .padding()
  }
}

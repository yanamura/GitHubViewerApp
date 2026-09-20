//
//  ReadmeView.swift
//  SampleGH
//

import SwiftUI

struct ReadmeView: View {
  let markdown: String

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      ForEach(Array(Self.parse(markdown).enumerated()), id: \.offset) { _, block in
        blockView(for: block)
      }
    }
  }

  @ViewBuilder
  private func blockView(for block: Block) -> some View {
    switch block {
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

  private enum Block {
    case heading(level: Int, text: String)
    case codeBlock(String)
    case paragraph(String)
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

  private static func parse(_ markdown: String) -> [Block] {
    var blocks: [Block] = []
    var paragraphLines: [String] = []
    var codeLines: [String]?

    func flushParagraph() {
      guard !paragraphLines.isEmpty else { return }
      let text = paragraphLines.joined(separator: " ").trimmingCharacters(in: .whitespaces)
      if !text.isEmpty {
        blocks.append(.paragraph(text))
      }
      paragraphLines.removeAll()
    }

    for rawLine in markdown.components(separatedBy: "\n") {
      let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)

      if line.hasPrefix("```") {
        if let lines = codeLines {
          blocks.append(.codeBlock(lines.joined(separator: "\n")))
          codeLines = nil
        } else {
          flushParagraph()
          codeLines = []
        }
        continue
      }

      if codeLines != nil {
        codeLines?.append(rawLine)
        continue
      }

      if line.isEmpty {
        flushParagraph()
        continue
      }

      let headingLevel = line.prefix(while: { $0 == "#" }).count
      if headingLevel > 0, headingLevel <= 6, line.count > headingLevel,
        line[line.index(line.startIndex, offsetBy: headingLevel)] == " "
      {
        flushParagraph()
        let text = line.dropFirst(headingLevel).trimmingCharacters(in: .whitespaces)
        blocks.append(.heading(level: headingLevel, text: text))
        continue
      }

      paragraphLines.append(line)
    }
    flushParagraph()
    if let lines = codeLines, !lines.isEmpty {
      blocks.append(.codeBlock(lines.joined(separator: "\n")))
    }
    return blocks
  }
}

#Preview {
  ScrollView {
    ReadmeView(
      markdown: """
        # Sample Repository

        This is a **sample** readme with _inline_ styling.

        ## Usage

        ```
        let value = 1
        ```
        """
    )
    .padding()
  }
}

//
//  ReadmeBlock.swift
//  SampleGH
//

import Foundation

/// READMEのMarkdownをブロック単位に分解したもの。
///
/// `id` はパース時に一度だけ採番する。`ForEach` の識別子を位置に依存させず、
/// かつ `body` の評価ごとに変わらないようにするため、ViewModelが保持する値としてのみ生成する。
struct ReadmeBlock: Identifiable, Equatable, Sendable {
  enum Kind: Equatable, Sendable {
    case heading(level: Int, text: String)
    case codeBlock(String)
    case paragraph(String)
  }

  let id = UUID()
  let kind: Kind

  static func parse(_ markdown: String) -> [ReadmeBlock] {
    var blocks: [ReadmeBlock] = []
    var paragraphLines: [String] = []
    var codeLines: [String]?

    func flushParagraph() {
      guard !paragraphLines.isEmpty else { return }
      let text = paragraphLines.joined(separator: " ").trimmingCharacters(in: .whitespaces)
      if !text.isEmpty {
        blocks.append(ReadmeBlock(kind: .paragraph(text)))
      }
      paragraphLines.removeAll()
    }

    for rawLine in markdown.components(separatedBy: "\n") {
      let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)

      if line.hasPrefix("```") {
        if let lines = codeLines {
          blocks.append(ReadmeBlock(kind: .codeBlock(lines.joined(separator: "\n"))))
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
        blocks.append(ReadmeBlock(kind: .heading(level: headingLevel, text: text)))
        continue
      }

      paragraphLines.append(line)
    }
    flushParagraph()
    if let lines = codeLines, !lines.isEmpty {
      blocks.append(ReadmeBlock(kind: .codeBlock(lines.joined(separator: "\n"))))
    }
    return blocks
  }
}

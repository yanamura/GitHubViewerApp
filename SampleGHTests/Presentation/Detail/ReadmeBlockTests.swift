//
//  ReadmeBlockTests.swift
//  SampleGHTests
//

import Foundation
import Testing

@testable import SampleGH

struct ReadmeBlockTests {
  @Test func parseSplitsHeadingParagraphAndCodeBlock() {
    let markdown = """
      # Title

      first line
      second line

      ```
      let value = 1
      ```
      """

    let kinds = ReadmeBlock.parse(markdown).map(\.kind)

    #expect(
      kinds == [
        .heading(level: 1, text: "Title"),
        .paragraph("first line second line"),
        .codeBlock("let value = 1"),
      ])
  }

  @Test func parseTreatsHashWithoutSpaceAsParagraph() {
    let kinds = ReadmeBlock.parse("#hashtag").map(\.kind)

    #expect(kinds == [.paragraph("#hashtag")])
  }

  @Test func parseKeepsUnterminatedCodeBlock() {
    let kinds = ReadmeBlock.parse("```\nlet value = 1").map(\.kind)

    #expect(kinds == [.codeBlock("let value = 1")])
  }

  @Test func parseAssignsUniqueIDs() {
    let blocks = ReadmeBlock.parse("# A\n\nB\n\nC")

    #expect(Set(blocks.map(\.id)).count == blocks.count)
  }

  @Test func parseReturnsEmptyForBlankInput() {
    #expect(ReadmeBlock.parse("").isEmpty)
    #expect(ReadmeBlock.parse("\n\n  \n").isEmpty)
  }
}

//
//  SearchRepositoriesResultTests.swift
//  SampleGHTests
//

import Foundation
import Testing

@testable import SampleGH

@MainActor
struct SearchRepositoriesResultTests {
  @Test func decodingMapsTotalsAndItemsFromJSON() throws {
    let json = """
      {
          "total_count": 2,
          "incomplete_results": true,
          "items": []
      }
      """.data(using: .utf8)!

    let result = try JSONDecoder().decode(SearchRepositoriesResult.self, from: json)

    #expect(result.totalCount == 2)
    #expect(result.incompleteResults == true)
    #expect(result.items.isEmpty)
  }
}

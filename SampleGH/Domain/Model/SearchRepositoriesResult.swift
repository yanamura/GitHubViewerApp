//
//  SearchRepositoriesResult.swift
//  SampleGH
//

struct SearchRepositoriesResult: Equatable, Sendable, Decodable {
  let totalCount: Int
  let incompleteResults: Bool
  let items: [Repository]

  enum CodingKeys: String, CodingKey {
    case totalCount = "total_count"
    case incompleteResults = "incomplete_results"
    case items
  }
}

//
//  Repository.swift
//  SampleGH
//

import Foundation

struct Repository: Identifiable, Hashable, Sendable, Codable {
  let id: Int
  let name: String
  let fullName: String
  let owner: Owner
  let description: String?
  let language: String?
  let stargazersCount: Int
  let forksCount: Int
  let openIssuesCount: Int
  let htmlURL: URL?
  let createdAt: Date
  let updatedAt: Date
  let license: License?

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case fullName = "full_name"
    case owner
    case description
    case language
    case stargazersCount = "stargazers_count"
    case forksCount = "forks_count"
    case openIssuesCount = "open_issues_count"
    case htmlURL = "html_url"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case license
  }
}

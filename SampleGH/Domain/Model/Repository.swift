//
//  Repository.swift
//  SampleGH
//

import Foundation

struct Repository: Identifiable, Equatable, Sendable, Decodable {
  let id: Int
  let name: String
  let fullName: String
  let owner: Owner
  let description: String?
  let language: String?
  let stargazersCount: Int
  let forksCount: Int
  let htmlURL: URL?

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case fullName = "full_name"
    case owner
    case description
    case language
    case stargazersCount = "stargazers_count"
    case forksCount = "forks_count"
    case htmlURL = "html_url"
  }
}

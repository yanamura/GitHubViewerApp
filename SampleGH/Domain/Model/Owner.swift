//
//  Owner.swift
//  SampleGH
//

import Foundation

struct Owner: Identifiable, Hashable, Sendable, Codable {
  let id: Int
  let login: String
  let avatarURL: URL?

  enum CodingKeys: String, CodingKey {
    case id
    case login
    case avatarURL = "avatar_url"
  }
}

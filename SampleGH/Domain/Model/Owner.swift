//
//  Owner.swift
//  SampleGH
//

import Foundation

struct Owner: Identifiable, Equatable, Sendable, Decodable {
  let id: Int
  let login: String
  let avatarURL: URL?

  enum CodingKeys: String, CodingKey {
    case id
    case login
    case avatarURL = "avatar_url"
  }
}

//
//  UserProfile.swift
//  SampleGH
//

import Foundation

struct UserProfile: Identifiable, Equatable, Sendable, Decodable {
  let id: Int
  let login: String
  let name: String?
  let bio: String?

  /// `name` が nil または空白のみの場合は `login` で代替する。
  var displayName: String {
    guard let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return login
    }
    return name
  }

  /// `bio` が nil または空白のみの場合は nil（= 非表示）。
  var displayBio: String? {
    guard let bio else { return nil }
    let trimmed = bio.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}

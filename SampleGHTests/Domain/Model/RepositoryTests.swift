//
//  RepositoryTests.swift
//  SampleGHTests
//

import Foundation
import Testing

@testable import SampleGH

struct RepositoryTests {
  @Test func decodingMapsSnakeCaseFieldsFromJSON() throws {
    let json = """
      {
          "id": 1,
          "name": "Repo",
          "full_name": "owner/Repo",
          "owner": { "id": 10, "login": "owner", "avatar_url": "https://example.com/avatar.png" },
          "description": null,
          "language": null,
          "stargazers_count": 5,
          "forks_count": 2,
          "html_url": "https://github.com/owner/Repo"
      }
      """.data(using: .utf8)!

    let repository = try JSONDecoder().decode(Repository.self, from: json)

    #expect(repository.id == 1)
    #expect(repository.name == "Repo")
    #expect(repository.fullName == "owner/Repo")
    #expect(repository.description == nil)
    #expect(repository.language == nil)
    #expect(repository.stargazersCount == 5)
    #expect(repository.forksCount == 2)
    #expect(repository.owner.login == "owner")
    #expect(repository.owner.avatarURL == URL(string: "https://example.com/avatar.png"))
    #expect(repository.htmlURL == URL(string: "https://github.com/owner/Repo"))
  }
}

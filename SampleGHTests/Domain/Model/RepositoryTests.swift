//
//  RepositoryTests.swift
//  SampleGHTests
//

import Foundation
import Testing

@testable import SampleGH

@MainActor
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
          "open_issues_count": 3,
          "html_url": "https://github.com/owner/Repo",
          "created_at": "2020-01-01T00:00:00Z",
          "updated_at": "2020-06-01T00:00:00Z",
          "license": { "name": "MIT License" }
      }
      """.data(using: .utf8)!

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let repository = try decoder.decode(Repository.self, from: json)

    #expect(repository.id == 1)
    #expect(repository.name == "Repo")
    #expect(repository.fullName == "owner/Repo")
    #expect(repository.description == nil)
    #expect(repository.language == nil)
    #expect(repository.stargazersCount == 5)
    #expect(repository.forksCount == 2)
    #expect(repository.openIssuesCount == 3)
    #expect(repository.owner.login == "owner")
    #expect(repository.owner.avatarURL == URL(string: "https://example.com/avatar.png"))
    #expect(repository.htmlURL == URL(string: "https://github.com/owner/Repo"))
    #expect(repository.createdAt == ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z"))
    #expect(repository.updatedAt == ISO8601DateFormatter().date(from: "2020-06-01T00:00:00Z"))
    #expect(repository.license == License(name: "MIT License"))
  }

  @Test func decodingHandlesMissingLicense() throws {
    let json = """
      {
          "id": 2,
          "name": "Repo2",
          "full_name": "owner/Repo2",
          "owner": { "id": 11, "login": "owner", "avatar_url": null },
          "description": "desc",
          "language": "Swift",
          "stargazers_count": 0,
          "forks_count": 0,
          "open_issues_count": 0,
          "html_url": "https://github.com/owner/Repo2",
          "created_at": "2020-01-01T00:00:00Z",
          "updated_at": "2020-01-01T00:00:00Z",
          "license": null
      }
      """.data(using: .utf8)!

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let repository = try decoder.decode(Repository.self, from: json)

    #expect(repository.license == nil)
  }
}

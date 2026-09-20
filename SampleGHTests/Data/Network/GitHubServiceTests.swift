//
//  GitHubServiceTests.swift
//  SampleGHTests
//

import Foundation
import Testing

@testable import SampleGH

@MainActor
struct GitHubServiceTests {
  private struct MockAPIClient: APIClientProtocol {
    let result: Result<(Data, URLResponse), Error>

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
      try result.get()
    }
  }

  private static let baseURL = URL(string: "https://api.github.com")!

  private static func response(statusCode: Int) -> URLResponse {
    HTTPURLResponse(url: baseURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
  }

  @Test func searchRepositoriesReturnsMappedResultOnSuccess() async throws {
    let json = """
      {
          "total_count": 1,
          "incomplete_results": false,
          "items": [
              {
                  "id": 1,
                  "name": "Repo",
                  "full_name": "owner/Repo",
                  "owner": { "id": 10, "login": "owner", "avatar_url": "https://example.com/avatar.png" },
                  "description": "A repo",
                  "language": "Swift",
                  "stargazers_count": 100,
                  "forks_count": 10,
                  "open_issues_count": 3,
                  "html_url": "https://github.com/owner/Repo",
                  "created_at": "2020-01-01T00:00:00Z",
                  "updated_at": "2020-06-01T00:00:00Z",
                  "license": null
              }
          ]
      }
      """.data(using: .utf8)!
    let apiClient = MockAPIClient(result: .success((json, Self.response(statusCode: 200))))
    let sut = GitHubService(apiClient: apiClient, baseURL: Self.baseURL)

    let result = try await sut.searchRepositories(query: "swift", page: 1)

    #expect(result.totalCount == 1)
    #expect(result.incompleteResults == false)
    #expect(result.items.count == 1)
    #expect(result.items[0].name == "Repo")
    #expect(result.items[0].owner.login == "owner")
    #expect(result.items[0].stargazersCount == 100)
  }

  @Test func searchRepositoriesThrowsRateLimitExceededOn403() async throws {
    let apiClient = MockAPIClient(result: .success((Data(), Self.response(statusCode: 403))))
    let sut = GitHubService(apiClient: apiClient, baseURL: Self.baseURL)

    await #expect(throws: GitHubServiceError.rateLimitExceeded) {
      try await sut.searchRepositories(query: "swift", page: 1)
    }
  }

  @Test func searchRepositoriesThrowsInvalidResponseOnUnexpectedStatusCode() async throws {
    let apiClient = MockAPIClient(result: .success((Data(), Self.response(statusCode: 500))))
    let sut = GitHubService(apiClient: apiClient, baseURL: Self.baseURL)

    await #expect(throws: GitHubServiceError.invalidResponse) {
      try await sut.searchRepositories(query: "swift", page: 1)
    }
  }

  @Test func searchRepositoriesThrowsDecodingFailedOnMalformedJSON() async throws {
    let malformedData = "not json".data(using: .utf8)!
    let apiClient = MockAPIClient(result: .success((malformedData, Self.response(statusCode: 200))))
    let sut = GitHubService(apiClient: apiClient, baseURL: Self.baseURL)

    await #expect(throws: GitHubServiceError.decodingFailed) {
      try await sut.searchRepositories(query: "swift", page: 1)
    }
  }

  @Test func fetchReadmeReturnsRawMarkdownOnSuccess() async throws {
    let markdown = "# Title\n\nBody text."
    let apiClient = MockAPIClient(
      result: .success((markdown.data(using: .utf8)!, Self.response(statusCode: 200))))
    let sut = GitHubService(apiClient: apiClient, baseURL: Self.baseURL)

    let result = try await sut.fetchReadme(owner: "owner", repo: "Repo")

    #expect(result == markdown)
  }

  @Test func fetchReadmeThrowsRateLimitExceededOn403() async throws {
    let apiClient = MockAPIClient(result: .success((Data(), Self.response(statusCode: 403))))
    let sut = GitHubService(apiClient: apiClient, baseURL: Self.baseURL)

    await #expect(throws: GitHubServiceError.rateLimitExceeded) {
      try await sut.fetchReadme(owner: "owner", repo: "Repo")
    }
  }

  @Test func fetchReadmeThrowsInvalidResponseOnUnexpectedStatusCode() async throws {
    let apiClient = MockAPIClient(result: .success((Data(), Self.response(statusCode: 404))))
    let sut = GitHubService(apiClient: apiClient, baseURL: Self.baseURL)

    await #expect(throws: GitHubServiceError.invalidResponse) {
      try await sut.fetchReadme(owner: "owner", repo: "Repo")
    }
  }
}

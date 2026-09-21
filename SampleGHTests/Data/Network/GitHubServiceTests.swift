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

  private actor RecordingAPIClient: APIClientProtocol {
    private(set) var requests: [URLRequest] = []
    private let statusCode: Int
    private let data: Data

    init(statusCode: Int = 200, data: Data = Data()) {
      self.statusCode = statusCode
      self.data = data
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
      requests.append(request)
      let response = HTTPURLResponse(
        url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
      return (data, response)
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

  // MARK: - fetchUserProfile

  @Test func fetchUserProfileReturnsMappedProfileOnSuccess() async throws {
    let json = """
      {
          "id": 583231,
          "login": "octocat",
          "avatar_url": "https://example.com/avatar.png",
          "name": "The Octocat",
          "bio": "Hello, world!"
      }
      """.data(using: .utf8)!
    let apiClient = MockAPIClient(result: .success((json, Self.response(statusCode: 200))))
    let sut = GitHubService(apiClient: apiClient, baseURL: Self.baseURL)

    let profile = try await sut.fetchUserProfile(login: "octocat")

    #expect(profile.id == 583231)
    #expect(profile.login == "octocat")
    #expect(profile.name == "The Octocat")
    #expect(profile.bio == "Hello, world!")
  }

  @Test func fetchUserProfileRequestsUsersLoginEndpoint() async throws {
    let json = #"{ "id": 1, "login": "octocat" }"#.data(using: .utf8)!
    let apiClient = RecordingAPIClient(data: json)
    let sut = GitHubService(
      apiClient: apiClient, tokenStorage: MockTokenStorage(), baseURL: Self.baseURL)

    _ = try await sut.fetchUserProfile(login: "octocat")

    let request = try #require(await apiClient.requests.first)
    #expect(request.url?.path == "/users/octocat")
    #expect(request.httpMethod == "GET")
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/vnd.github+json")
  }

  @Test func fetchUserProfileIncludesBearerTokenWhenTokenIsSaved() async throws {
    let json = #"{ "id": 1, "login": "octocat" }"#.data(using: .utf8)!
    let apiClient = RecordingAPIClient(data: json)
    let sut = GitHubService(
      apiClient: apiClient, tokenStorage: MockTokenStorage(token: "ghp_saved"),
      baseURL: Self.baseURL)

    _ = try await sut.fetchUserProfile(login: "octocat")

    let request = try #require(await apiClient.requests.first)
    #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer ghp_saved")
  }

  @Test func fetchUserProfileThrowsRateLimitExceededOn403() async throws {
    let apiClient = MockAPIClient(result: .success((Data(), Self.response(statusCode: 403))))
    let sut = GitHubService(apiClient: apiClient, baseURL: Self.baseURL)

    await #expect(throws: GitHubServiceError.rateLimitExceeded) {
      try await sut.fetchUserProfile(login: "octocat")
    }
  }

  @Test func fetchUserProfileThrowsInvalidResponseOn404() async throws {
    let apiClient = MockAPIClient(result: .success((Data(), Self.response(statusCode: 404))))
    let sut = GitHubService(apiClient: apiClient, baseURL: Self.baseURL)

    await #expect(throws: GitHubServiceError.invalidResponse) {
      try await sut.fetchUserProfile(login: "octocat")
    }
  }

  @Test func fetchUserProfileThrowsDecodingFailedOnMalformedJSON() async throws {
    let malformedData = "not json".data(using: .utf8)!
    let apiClient = MockAPIClient(result: .success((malformedData, Self.response(statusCode: 200))))
    let sut = GitHubService(apiClient: apiClient, baseURL: Self.baseURL)

    await #expect(throws: GitHubServiceError.decodingFailed) {
      try await sut.fetchUserProfile(login: "octocat")
    }
  }

  // MARK: - Authorization header

  @Test func requestIncludesBearerTokenWhenTokenIsSaved() async throws {
    let apiClient = RecordingAPIClient(data: "# Title".data(using: .utf8)!)
    let sut = GitHubService(
      apiClient: apiClient, tokenStorage: MockTokenStorage(token: "ghp_saved"),
      baseURL: Self.baseURL)

    _ = try await sut.fetchReadme(owner: "owner", repo: "Repo")

    let request = try #require(await apiClient.requests.first)
    #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer ghp_saved")
  }

  @Test func requestOmitsAuthorizationHeaderWhenNoTokenIsSaved() async throws {
    let apiClient = RecordingAPIClient(data: "# Title".data(using: .utf8)!)
    let sut = GitHubService(
      apiClient: apiClient, tokenStorage: MockTokenStorage(), baseURL: Self.baseURL)

    _ = try await sut.fetchReadme(owner: "owner", repo: "Repo")

    let request = try #require(await apiClient.requests.first)
    #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
  }

  // MARK: - validateToken

  @Test func validateTokenSendsGivenTokenToUserEndpoint() async throws {
    let apiClient = RecordingAPIClient()
    let sut = GitHubService(
      apiClient: apiClient, tokenStorage: MockTokenStorage(token: "ghp_saved"),
      baseURL: Self.baseURL)

    try await sut.validateToken("ghp_input")

    let request = try #require(await apiClient.requests.first)
    #expect(request.url?.path == "/user")
    #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer ghp_input")
  }

  @Test func validateTokenThrowsUnauthorizedOn401() async throws {
    let apiClient = MockAPIClient(result: .success((Data(), Self.response(statusCode: 401))))
    let sut = GitHubService(
      apiClient: apiClient, tokenStorage: MockTokenStorage(), baseURL: Self.baseURL)

    await #expect(throws: GitHubServiceError.unauthorized) {
      try await sut.validateToken("bad")
    }
  }

  @Test func validateTokenThrowsRateLimitExceededOn403() async throws {
    let apiClient = MockAPIClient(result: .success((Data(), Self.response(statusCode: 403))))
    let sut = GitHubService(
      apiClient: apiClient, tokenStorage: MockTokenStorage(), baseURL: Self.baseURL)

    await #expect(throws: GitHubServiceError.rateLimitExceeded) {
      try await sut.validateToken("token")
    }
  }

  @Test func validateTokenThrowsInvalidResponseOnUnexpectedStatusCode() async throws {
    let apiClient = MockAPIClient(result: .success((Data(), Self.response(statusCode: 500))))
    let sut = GitHubService(
      apiClient: apiClient, tokenStorage: MockTokenStorage(), baseURL: Self.baseURL)

    await #expect(throws: GitHubServiceError.invalidResponse) {
      try await sut.validateToken("token")
    }
  }
}

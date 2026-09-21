//
//  GitHubService.swift
//  SampleGH
//

import Foundation

final class GitHubService: GitHubServiceProtocol {
  private let apiClient: APIClientProtocol
  private let tokenStorage: TokenStorageProtocol
  private let baseURL: URL
  private let decoder: JSONDecoder

  init(
    apiClient: APIClientProtocol = URLSessionAPIClient(),
    tokenStorage: TokenStorageProtocol = KeychainManager(),
    baseURL: URL = URL(string: "https://api.github.com")!
  ) {
    self.apiClient = apiClient
    self.tokenStorage = tokenStorage
    self.baseURL = baseURL
    self.decoder = JSONDecoder()
    self.decoder.dateDecodingStrategy = .iso8601
  }

  func searchRepositories(query: String, page: Int) async throws -> SearchRepositoriesResult {
    guard
      var components = URLComponents(
        url: baseURL.appendingPathComponent("search/repositories"),
        resolvingAgainstBaseURL: false
      )
    else {
      throw GitHubServiceError.invalidResponse
    }
    components.queryItems = [
      URLQueryItem(name: "q", value: query),
      URLQueryItem(name: "page", value: String(page)),
      URLQueryItem(name: "per_page", value: "30"),
    ]
    guard let url = components.url else {
      throw GitHubServiceError.invalidResponse
    }

    let request = await makeRequest(url: url, accept: "application/vnd.github+json")

    let (data, response) = try await apiClient.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw GitHubServiceError.invalidResponse
    }

    switch httpResponse.statusCode {
    case 200:
      break
    case 403:
      throw GitHubServiceError.rateLimitExceeded
    default:
      throw GitHubServiceError.invalidResponse
    }

    do {
      return try decoder.decode(SearchRepositoriesResult.self, from: data)
    } catch {
      throw GitHubServiceError.decodingFailed
    }
  }

  func fetchReadme(owner: String, repo: String) async throws -> String {
    let url =
      baseURL
      .appendingPathComponent("repos")
      .appendingPathComponent(owner)
      .appendingPathComponent(repo)
      .appendingPathComponent("readme")

    let request = await makeRequest(url: url, accept: "application/vnd.github.raw+json")

    let (data, response) = try await apiClient.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw GitHubServiceError.invalidResponse
    }

    switch httpResponse.statusCode {
    case 200:
      break
    case 403:
      throw GitHubServiceError.rateLimitExceeded
    default:
      throw GitHubServiceError.invalidResponse
    }

    guard let markdown = String(data: data, encoding: .utf8) else {
      throw GitHubServiceError.decodingFailed
    }
    return markdown
  }

  func validateToken(_ token: String) async throws {
    let url = baseURL.appendingPathComponent("user")
    let request = await makeRequest(url: url, accept: "application/vnd.github+json", token: token)

    let (_, response) = try await apiClient.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw GitHubServiceError.invalidResponse
    }

    switch httpResponse.statusCode {
    case 200:
      break
    case 401:
      throw GitHubServiceError.unauthorized
    case 403:
      throw GitHubServiceError.rateLimitExceeded
    default:
      throw GitHubServiceError.invalidResponse
    }
  }

  /// `token` を省略した場合はKeychainに保存済みのPATを使う。未保存なら未認証リクエストになる。
  private func makeRequest(url: URL, accept: String, token: String? = nil) async -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(accept, forHTTPHeaderField: "Accept")
    let resolvedToken = if let token { token } else { await tokenStorage.loadToken() }
    if let resolvedToken {
      request.setValue("Bearer \(resolvedToken)", forHTTPHeaderField: "Authorization")
    }
    return request
  }
}

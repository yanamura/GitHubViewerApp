//
//  GitHubService.swift
//  SampleGH
//

import Foundation

final class GitHubService: GitHubServiceProtocol {
  private let apiClient: APIClientProtocol
  private let baseURL: URL
  private let decoder: JSONDecoder

  init(
    apiClient: APIClientProtocol = URLSessionAPIClient(),
    baseURL: URL = URL(string: "https://api.github.com")!
  ) {
    self.apiClient = apiClient
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

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

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

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/vnd.github.raw+json", forHTTPHeaderField: "Accept")

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
}

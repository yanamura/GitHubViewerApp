//
//  GitHubServiceProtocol.swift
//  SampleGH
//

protocol GitHubServiceProtocol: Sendable {
  func searchRepositories(query: String, page: Int) async throws -> SearchRepositoriesResult
  func fetchReadme(owner: String, repo: String) async throws -> String
}

//
//  GitHubServiceProtocol.swift
//  SampleGH
//

protocol GitHubServiceProtocol: Sendable {
  func searchRepositories(query: String, page: Int) async throws -> SearchRepositoriesResult
}

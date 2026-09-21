//
//  GitHubServiceProtocol.swift
//  SampleGH
//

protocol GitHubServiceProtocol: Sendable {
  func searchRepositories(query: String, page: Int) async throws -> SearchRepositoriesResult
  func fetchReadme(owner: String, repo: String) async throws -> String
  /// 指定したPATがGitHub APIで有効かを確認する。無効な場合は `GitHubServiceError.unauthorized` を投げる。
  func validateToken(_ token: String) async throws
}

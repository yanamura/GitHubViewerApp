//
//  GitHubServiceError.swift
//  SampleGH
//

enum GitHubServiceError: Error, Equatable, Sendable {
  case rateLimitExceeded
  case invalidResponse
  case decodingFailed
}

//
//  GitHubServiceError.swift
//  SampleGH
//

enum GitHubServiceError: Error, Equatable, Sendable {
  case rateLimitExceeded
  case unauthorized
  case invalidResponse
  case decodingFailed
}

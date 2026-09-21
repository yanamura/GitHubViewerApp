//
//  MockTokenStorage.swift
//  SampleGHTests
//

@testable import SampleGH

actor MockTokenStorage: TokenStorageProtocol {
  private var token: String?

  init(token: String? = nil) {
    self.token = token
  }

  func loadToken() async -> String? {
    token
  }

  func saveToken(_ token: String) async throws {
    self.token = token
  }

  func deleteToken() async throws {
    token = nil
  }
}

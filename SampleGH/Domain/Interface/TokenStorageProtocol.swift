//
//  TokenStorageProtocol.swift
//  SampleGH
//

protocol TokenStorageProtocol: Sendable {
  func loadToken() async -> String?
  func saveToken(_ token: String) async throws
  func deleteToken() async throws
}

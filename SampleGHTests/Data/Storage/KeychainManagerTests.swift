//
//  KeychainManagerTests.swift
//  SampleGHTests
//

import Foundation
import Testing

@testable import SampleGH

@MainActor
struct KeychainManagerTests {
  /// テスト間・実アプリのKeychainと干渉しないよう、毎回ユニークなserviceを使う。
  private func makeSUT() -> KeychainManager {
    KeychainManager(service: "KeychainManagerTests.\(UUID().uuidString)", account: "token")
  }

  @Test func loadTokenReturnsNilWhenNothingSaved() async throws {
    let sut = makeSUT()

    #expect(await sut.loadToken() == nil)
  }

  @Test func saveTokenThenLoadTokenReturnsSavedValue() async throws {
    let sut = makeSUT()

    try await sut.saveToken("ghp_first")
    defer { Task { try? await sut.deleteToken() } }

    #expect(await sut.loadToken() == "ghp_first")
  }

  @Test func saveTokenOverwritesExistingValue() async throws {
    let sut = makeSUT()
    try await sut.saveToken("ghp_first")
    defer { Task { try? await sut.deleteToken() } }

    try await sut.saveToken("ghp_second")

    #expect(await sut.loadToken() == "ghp_second")
  }

  @Test func deleteTokenRemovesSavedValue() async throws {
    let sut = makeSUT()
    try await sut.saveToken("ghp_first")

    try await sut.deleteToken()

    #expect(await sut.loadToken() == nil)
  }

  @Test func deleteTokenDoesNotThrowWhenNothingSaved() async throws {
    let sut = makeSUT()

    try await sut.deleteToken()

    #expect(await sut.loadToken() == nil)
  }
}

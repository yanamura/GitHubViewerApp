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

  // MARK: - Cache

  /// 同じKeychain項目を別インスタンスから書き換えても、一度読み込んだ値はキャッシュから返る。
  @Test func loadTokenReturnsCachedValueWithoutReadingKeychainAgain() async throws {
    let service = "KeychainManagerTests.\(UUID().uuidString)"
    let sut = KeychainManager(service: service, account: "token")
    let other = KeychainManager(service: service, account: "token")
    try await sut.saveToken("ghp_first")
    defer { Task { try? await sut.deleteToken() } }

    try await other.saveToken("ghp_changed_elsewhere")

    #expect(await sut.loadToken() == "ghp_first")
  }

  @Test func loadTokenCachesNilWhenNothingSaved() async throws {
    let service = "KeychainManagerTests.\(UUID().uuidString)"
    let sut = KeychainManager(service: service, account: "token")
    let other = KeychainManager(service: service, account: "token")
    #expect(await sut.loadToken() == nil)

    try await other.saveToken("ghp_changed_elsewhere")
    defer { Task { try? await other.deleteToken() } }

    #expect(await sut.loadToken() == nil)
  }

  @Test func deleteTokenClearsCachedValue() async throws {
    let sut = makeSUT()
    try await sut.saveToken("ghp_first")
    #expect(await sut.loadToken() == "ghp_first")

    try await sut.deleteToken()

    #expect(await sut.loadToken() == nil)
  }
}

//
//  SettingsViewModel.swift
//  SampleGH
//

import Foundation

@MainActor
@Observable
final class SettingsViewModel {
  enum Status: Equatable {
    case success(String)
    case failure(String)
  }

  var tokenInput: String = ""
  private(set) var hasSavedToken = false
  private(set) var isSaving = false
  private(set) var status: Status?

  private let tokenStorage: TokenStorageProtocol
  private let gitHubService: GitHubServiceProtocol

  init(
    tokenStorage: TokenStorageProtocol = KeychainManager(),
    gitHubService: GitHubServiceProtocol = GitHubService()
  ) {
    self.tokenStorage = tokenStorage
    self.gitHubService = gitHubService
  }

  var canSave: Bool {
    !isSaving && !trimmedToken.isEmpty
  }

  func onAppear() async {
    guard let token = await tokenStorage.loadToken() else {
      hasSavedToken = false
      return
    }
    tokenInput = token
    hasSavedToken = true
  }

  /// 疎通確認に成功した場合のみKeychainへ保存する。
  func save() async {
    let token = trimmedToken
    guard !token.isEmpty else { return }

    isSaving = true
    status = nil
    defer { isSaving = false }

    do {
      try await gitHubService.validateToken(token)
    } catch {
      status = .failure(Self.errorMessage(for: error))
      return
    }

    do {
      try await tokenStorage.saveToken(token)
      tokenInput = token
      hasSavedToken = true
      status = .success("トークンを保存しました。")
    } catch {
      status = .failure("トークンの保存に失敗しました。")
    }
  }

  func delete() async {
    status = nil
    do {
      try await tokenStorage.deleteToken()
      tokenInput = ""
      hasSavedToken = false
      status = .success("トークンを削除しました。")
    } catch {
      status = .failure("トークンの削除に失敗しました。")
    }
  }

  private var trimmedToken: String {
    tokenInput.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private static func errorMessage(for error: Error) -> String {
    switch error as? GitHubServiceError {
    case .unauthorized:
      return "トークンが無効です。入力内容を確認してください。"
    case .rateLimitExceeded:
      return "APIのレート制限に達しました。しばらくしてから再度お試しください。"
    default:
      return "通信エラーが発生しました。もう一度お試しください。"
    }
  }
}

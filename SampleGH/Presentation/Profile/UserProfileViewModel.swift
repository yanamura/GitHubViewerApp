//
//  UserProfileViewModel.swift
//  SampleGH
//

import Foundation

@MainActor
@Observable
final class UserProfileViewModel {
  enum State: Equatable {
    case loading
    case loaded(UserProfile)
    case error(String)
  }

  let owner: Owner
  private(set) var state: State = .loading

  private let gitHubService: GitHubServiceProtocol

  init(owner: Owner, gitHubService: GitHubServiceProtocol = GitHubService()) {
    self.owner = owner
    self.gitHubService = gitHubService
  }

  func onAppear() async {
    await load()
  }

  func retry() async {
    await load()
  }

  private func load() async {
    state = .loading
    do {
      state = .loaded(try await gitHubService.fetchUserProfile(login: owner.login))
    } catch {
      // シートを閉じて `.task` がキャンセルされた場合はエラー表示にしない。
      if Task.isCancelled { return }
      state = .error(Self.errorMessage(for: error))
    }
  }

  private static func errorMessage(for error: Error) -> String {
    switch error as? GitHubServiceError {
    case .rateLimitExceeded:
      return "APIのレート制限に達しました。しばらくしてから再度お試しください。"
    default:
      return "通信エラーが発生しました。もう一度お試しください。"
    }
  }
}

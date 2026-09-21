//
//  UserProfileViewModelTests.swift
//  SampleGHTests
//

import Foundation
import Testing

@testable import SampleGH

@MainActor
struct UserProfileViewModelTests {
  private actor MockGitHubService: GitHubServiceProtocol {
    private var userProfileResults: [Result<UserProfile, Error>]
    private(set) var fetchedLogins: [String] = []

    init(userProfileResults: [Result<UserProfile, Error>]) {
      self.userProfileResults = userProfileResults
    }

    func fetchUserProfile(login: String) async throws -> UserProfile {
      fetchedLogins.append(login)
      return try userProfileResults.removeFirst().get()
    }

    func searchRepositories(query: String, page: Int) async throws -> SearchRepositoriesResult {
      throw GitHubServiceError.invalidResponse
    }

    func fetchReadme(owner: String, repo: String) async throws -> String {
      throw GitHubServiceError.invalidResponse
    }

    func validateToken(_ token: String) async throws {
      throw GitHubServiceError.invalidResponse
    }
  }

  private static let owner = Owner(id: 1, login: "octocat", avatarURL: nil)
  private static let profile = UserProfile(
    id: 1, login: "octocat", name: "The Octocat", bio: "Hello, world!")

  @Test func initialStateIsLoading() {
    let sut = UserProfileViewModel(
      owner: Self.owner, gitHubService: MockGitHubService(userProfileResults: []))

    #expect(sut.state == .loading)
  }

  @Test func onAppearLoadsProfileForOwnerLogin() async {
    let service = MockGitHubService(userProfileResults: [.success(Self.profile)])
    let sut = UserProfileViewModel(owner: Self.owner, gitHubService: service)

    await sut.onAppear()

    #expect(sut.state == .loaded(Self.profile))
    #expect(await service.fetchedLogins == ["octocat"])
  }

  @Test func onAppearShowsRateLimitMessageOnRateLimitExceeded() async {
    let service = MockGitHubService(userProfileResults: [
      .failure(GitHubServiceError.rateLimitExceeded)
    ])
    let sut = UserProfileViewModel(owner: Self.owner, gitHubService: service)

    await sut.onAppear()

    #expect(sut.state == .error("APIのレート制限に達しました。しばらくしてから再度お試しください。"))
  }

  @Test func onAppearShowsGenericMessageOnOtherErrors() async {
    let service = MockGitHubService(userProfileResults: [
      .failure(GitHubServiceError.invalidResponse)
    ])
    let sut = UserProfileViewModel(owner: Self.owner, gitHubService: service)

    await sut.onAppear()

    #expect(sut.state == .error("通信エラーが発生しました。もう一度お試しください。"))
  }

  @Test func retryLoadsProfileAfterError() async {
    let service = MockGitHubService(userProfileResults: [
      .failure(GitHubServiceError.invalidResponse),
      .success(Self.profile),
    ])
    let sut = UserProfileViewModel(owner: Self.owner, gitHubService: service)

    await sut.onAppear()
    await sut.retry()

    #expect(sut.state == .loaded(Self.profile))
    #expect(await service.fetchedLogins == ["octocat", "octocat"])
  }
}

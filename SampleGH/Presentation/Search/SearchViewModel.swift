//
//  SearchViewModel.swift
//  SampleGH
//

import Foundation

@MainActor
@Observable
final class SearchViewModel {
  enum Phase: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
  }

  var query: String = ""
  private(set) var repositories: [Repository] = []
  private(set) var phase: Phase = .idle
  private(set) var isLoadingNextPage = false

  private let gitHubService: GitHubServiceProtocol
  private var searchedQuery = ""
  private var currentPage = 1
  private var hasMorePages = true

  init(gitHubService: GitHubServiceProtocol = GitHubService()) {
    self.gitHubService = gitHubService
  }

  /// デバウンス用。`.task(id: query)` から呼ばれ、queryが変わると自動的にキャンセルされる。
  func onQueryChanged() async {
    do {
      try await Task.sleep(for: .milliseconds(500))
    } catch {
      return
    }
    await search()
  }

  func submitSearch() async {
    await search()
  }

  func retry() async {
    await search()
  }

  func loadNextPageIfNeeded(currentItem repository: Repository) async {
    guard
      hasMorePages,
      !isLoadingNextPage,
      repository.id == repositories.last?.id
    else { return }

    isLoadingNextPage = true
    defer { isLoadingNextPage = false }

    let nextPage = currentPage + 1
    do {
      let result = try await gitHubService.searchRepositories(query: searchedQuery, page: nextPage)
      currentPage = nextPage
      repositories.append(contentsOf: result.items)
      hasMorePages = !result.items.isEmpty && repositories.count < result.totalCount
    } catch {
      hasMorePages = false
    }
  }

  private func search() async {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      searchedQuery = ""
      repositories = []
      phase = .idle
      return
    }

    searchedQuery = trimmed
    currentPage = 1
    hasMorePages = true
    phase = .loading

    do {
      let result = try await gitHubService.searchRepositories(query: trimmed, page: 1)
      guard trimmed == searchedQuery else { return }
      repositories = result.items
      hasMorePages = !result.items.isEmpty && result.items.count < result.totalCount
      phase = .loaded
    } catch {
      guard trimmed == searchedQuery else { return }
      repositories = []
      phase = .error(Self.errorMessage(for: error))
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

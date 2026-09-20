//
//  ExploreViewModel.swift
//  SampleGH
//

import Foundation

enum ExploreLanguageFilter: String, CaseIterable, Identifiable, Hashable, Sendable {
  case all = "All"
  case swift = "Swift"
  case kotlin = "Kotlin"
  case rust = "Rust"
  case python = "Python"
  case typeScript = "TypeScript"

  var id: String { rawValue }

  fileprivate var queryFragment: String? {
    self == .all ? nil : "language:\(rawValue)"
  }
}

@MainActor
@Observable
final class ExploreViewModel {
  enum Phase: Equatable {
    case loading
    case loaded
    case error(String)
  }

  var languageFilter: ExploreLanguageFilter = .all
  private(set) var repositories: [Repository] = []
  private(set) var phase: Phase = .loading

  private let gitHubService: GitHubServiceProtocol
  private let calendar: Calendar

  init(gitHubService: GitHubServiceProtocol = GitHubService(), calendar: Calendar = .current) {
    self.gitHubService = gitHubService
    self.calendar = calendar
  }

  /// `.task(id: languageFilter)` から呼ばれる。初期表示時とフィルタ変更時の両方でフルスクリーンローディングを表示する。
  func load() async {
    phase = .loading
    await fetch()
  }

  /// Pull to Refreshから呼ばれる。既存の一覧を表示したまま裏で再取得する。
  func refresh() async {
    await fetch()
  }

  func retry() async {
    await load()
  }

  private func fetch() async {
    do {
      let result = try await gitHubService.searchRepositories(query: query, page: 1)
      repositories = result.items
      phase = .loaded
    } catch {
      repositories = []
      phase = .error(Self.errorMessage(for: error))
    }
  }

  private var query: String {
    var qualifiers = ["created:>\(oneMonthAgoDateString)", "sort:stars"]
    if let fragment = languageFilter.queryFragment {
      qualifiers.append(fragment)
    }
    return qualifiers.joined(separator: " ")
  }

  private var oneMonthAgoDateString: String {
    let date = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(identifier: "UTC")
    return formatter.string(from: date)
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

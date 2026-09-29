//
//  DetailViewModel.swift
//  SampleGH
//

import Dependencies
import Foundation

@MainActor
@Observable
final class DetailViewModel {
  enum ReadmeState: Equatable {
    case loading
    case loaded(String)
    case error(String)
  }

  let repository: Repository
  private(set) var readmeState: ReadmeState = .loading
  private(set) var isFavorite = false

  @ObservationIgnored @Dependency(\.gitHubService) private var gitHubService
  @ObservationIgnored @Dependency(\.favoritesStorage) private var favoritesStorage

  init(repository: Repository) {
    self.repository = repository
  }

  func onAppear() async {
    isFavorite = await favoritesStorage.isFavorite(id: repository.id)
    await loadReadme()
  }

  func retryReadme() async {
    await loadReadme()
  }

  func toggleFavorite() async {
    if isFavorite {
      await favoritesStorage.remove(id: repository.id)
    } else {
      await favoritesStorage.add(repository)
    }
    isFavorite.toggle()
  }

  private func loadReadme() async {
    readmeState = .loading
    do {
      let markdown = try await gitHubService.fetchReadme(
        owner: repository.owner.login, repo: repository.name)
      readmeState = .loaded(markdown)
    } catch {
      readmeState = .error("READMEを取得できませんでした。")
    }
  }
}

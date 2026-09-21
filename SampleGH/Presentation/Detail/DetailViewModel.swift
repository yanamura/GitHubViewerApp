//
//  DetailViewModel.swift
//  SampleGH
//

import Foundation

@MainActor
@Observable
final class DetailViewModel {
  enum ReadmeState: Equatable {
    case loading
    case loaded([ReadmeBlock])
    case error(String)
  }

  let repository: Repository
  private(set) var readmeState: ReadmeState = .loading
  private(set) var isFavorite = false

  private let gitHubService: GitHubServiceProtocol
  private let favoritesStorage: FavoritesStorageProtocol

  init(
    repository: Repository,
    gitHubService: GitHubServiceProtocol = GitHubService(),
    favoritesStorage: FavoritesStorageProtocol = LocalFavoritesDataSource()
  ) {
    self.repository = repository
    self.gitHubService = gitHubService
    self.favoritesStorage = favoritesStorage
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
      readmeState = .loaded(ReadmeBlock.parse(markdown))
    } catch {
      readmeState = .error("READMEを取得できませんでした。")
    }
  }
}

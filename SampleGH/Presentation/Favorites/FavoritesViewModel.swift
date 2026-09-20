//
//  FavoritesViewModel.swift
//  SampleGH
//

import Foundation

@MainActor
@Observable
final class FavoritesViewModel {
  private(set) var repositories: [Repository] = []

  private let favoritesStorage: FavoritesStorageProtocol

  init(favoritesStorage: FavoritesStorageProtocol = LocalFavoritesDataSource()) {
    self.favoritesStorage = favoritesStorage
  }

  func onAppear() async {
    await reload()
  }

  func remove(_ repository: Repository) async {
    await favoritesStorage.remove(id: repository.id)
    await reload()
  }

  private func reload() async {
    repositories = await favoritesStorage.fetchAll()
  }
}

//
//  LocalFavoritesDataSource.swift
//  SampleGH
//

import Foundation

actor LocalFavoritesDataSource: FavoritesStorageProtocol {
  private let defaults: UserDefaults
  private let storageKey = "com.samplegh.favorites"

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  func fetchAll() async -> [Repository] {
    load()
  }

  func isFavorite(id: Int) async -> Bool {
    load().contains { $0.id == id }
  }

  func add(_ repository: Repository) async {
    var repositories = load()
    guard !repositories.contains(where: { $0.id == repository.id }) else { return }
    repositories.append(repository)
    save(repositories)
  }

  func remove(id: Int) async {
    var repositories = load()
    repositories.removeAll { $0.id == id }
    save(repositories)
  }

  private func load() -> [Repository] {
    guard let data = defaults.data(forKey: storageKey) else { return [] }
    return (try? JSONDecoder().decode([Repository].self, from: data)) ?? []
  }

  private func save(_ repositories: [Repository]) {
    guard let data = try? JSONEncoder().encode(repositories) else { return }
    defaults.set(data, forKey: storageKey)
  }
}

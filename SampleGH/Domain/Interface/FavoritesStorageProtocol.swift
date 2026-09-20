//
//  FavoritesStorageProtocol.swift
//  SampleGH
//

protocol FavoritesStorageProtocol: Sendable {
  func fetchAll() async -> [Repository]
  func isFavorite(id: Int) async -> Bool
  func add(_ repository: Repository) async
  func remove(id: Int) async
}

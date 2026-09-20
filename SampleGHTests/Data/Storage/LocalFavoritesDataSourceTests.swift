//
//  LocalFavoritesDataSourceTests.swift
//  SampleGHTests
//

import Foundation
import Testing

@testable import SampleGH

struct LocalFavoritesDataSourceTests {
  private static func makeRepository(id: Int) -> Repository {
    Repository(
      id: id,
      name: "Repo\(id)",
      fullName: "owner/Repo\(id)",
      owner: Owner(id: 1, login: "owner", avatarURL: nil),
      description: nil,
      language: nil,
      stargazersCount: 0,
      forksCount: 0,
      openIssuesCount: 0,
      htmlURL: nil,
      createdAt: Date(timeIntervalSince1970: 0),
      updatedAt: Date(timeIntervalSince1970: 0),
      license: nil
    )
  }

  private func makeSUT() -> LocalFavoritesDataSource {
    let suiteName = "LocalFavoritesDataSourceTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    return LocalFavoritesDataSource(defaults: defaults)
  }

  @Test func addAppendsRepositoryAndMarksItFavorite() async throws {
    let sut = makeSUT()
    let repository = Self.makeRepository(id: 1)

    await sut.add(repository)

    #expect(await sut.isFavorite(id: 1))
    #expect(await sut.fetchAll() == [repository])
  }

  @Test func addIsIdempotentForSameID() async throws {
    let sut = makeSUT()
    let repository = Self.makeRepository(id: 1)

    await sut.add(repository)
    await sut.add(repository)

    #expect(await sut.fetchAll().count == 1)
  }

  @Test func removeDeletesFavorite() async throws {
    let sut = makeSUT()
    let repository = Self.makeRepository(id: 1)
    await sut.add(repository)

    await sut.remove(id: 1)

    #expect(await sut.isFavorite(id: 1) == false)
    #expect(await sut.fetchAll().isEmpty)
  }

  @Test func isFavoriteReturnsFalseWhenEmpty() async throws {
    let sut = makeSUT()

    #expect(await sut.isFavorite(id: 999) == false)
  }
}

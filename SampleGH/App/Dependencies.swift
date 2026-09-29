//
//  Dependencies.swift
//  SampleGH
//

import Dependencies

extension DependencyValues {
  var tokenStorage: any TokenStorageProtocol {
    get { self[TokenStorageKey.self] }
    set { self[TokenStorageKey.self] = newValue }
  }

  var gitHubService: any GitHubServiceProtocol {
    get { self[GitHubServiceKey.self] }
    set { self[GitHubServiceKey.self] = newValue }
  }

  var favoritesStorage: any FavoritesStorageProtocol {
    get { self[FavoritesStorageKey.self] }
    set { self[FavoritesStorageKey.self] = newValue }
  }
}

// `liveValue` は swift-dependencies により一度だけ生成・キャッシュされ、アプリ全体で同じインスタンスが共有される。
// テストで上書きせずにアクセスした場合は、swift-dependencies がテスト失敗として報告する。

private enum TokenStorageKey: DependencyKey {
  static let liveValue: any TokenStorageProtocol = KeychainManager()
}

private enum GitHubServiceKey: DependencyKey {
  /// トークンのキャッシュを設定画面と共有するため、`tokenStorage` の依存を使って生成する。
  static var liveValue: any GitHubServiceProtocol {
    @Dependency(\.tokenStorage) var tokenStorage
    return GitHubService(tokenStorage: tokenStorage)
  }
}

private enum FavoritesStorageKey: DependencyKey {
  static let liveValue: any FavoritesStorageProtocol = LocalFavoritesDataSource()
}

//
//  PreviewSupport.swift
//  SampleGH
//

#if DEBUG
  import Foundation

  // Preview専用のサンプルデータとモック。ネットワーク・Keychain・UserDefaultsに触れずに即座に描画するために使う。

  extension Owner {
    static let preview = Owner(id: 1, login: "apple", avatarURL: nil)
  }

  extension Repository {
    static let preview = Repository(
      id: 1,
      name: "swift",
      fullName: "apple/swift",
      owner: .preview,
      description: "The Swift Programming Language",
      language: "Swift",
      stargazersCount: 12345,
      forksCount: 678,
      openIssuesCount: 42,
      htmlURL: nil,
      createdAt: Date(timeIntervalSince1970: 0),
      updatedAt: Date(timeIntervalSince1970: 1_700_000_000),
      license: License(name: "Apache License 2.0")
    )

    static let previews: [Repository] = [
      .preview,
      Repository(
        id: 2,
        name: "swift-testing",
        fullName: "swiftlang/swift-testing",
        owner: Owner(id: 2, login: "swiftlang", avatarURL: nil),
        description: "A modern, macro-based testing library for Swift.",
        language: "Swift",
        stargazersCount: 1500,
        forksCount: 120,
        openIssuesCount: 30,
        htmlURL: nil,
        createdAt: Date(timeIntervalSince1970: 0),
        updatedAt: Date(timeIntervalSince1970: 1_700_000_000),
        license: nil
      ),
    ]
  }

  extension UserProfile {
    static let preview = UserProfile(
      id: 1, login: "apple", name: "Apple", bio: "Everyone has a story to tell.")
  }

  struct PreviewGitHubService: GitHubServiceProtocol {
    var repositories: [Repository] = Repository.previews
    var error: GitHubServiceError?

    func searchRepositories(query: String, page: Int) async throws -> SearchRepositoriesResult {
      if let error { throw error }
      return SearchRepositoriesResult(
        totalCount: repositories.count, incompleteResults: false, items: repositories)
    }

    func fetchReadme(owner: String, repo: String) async throws -> String {
      if let error { throw error }
      return """
        # \(repo)

        This is a **sample** readme with _inline_ styling.

        ## Usage

        ```
        let value = 1
        ```
        """
    }

    func fetchUserProfile(login: String) async throws -> UserProfile {
      if let error { throw error }
      return .preview
    }

    func validateToken(_ token: String) async throws {
      if let error { throw error }
    }
  }

  actor PreviewFavoritesStorage: FavoritesStorageProtocol {
    private var repositories: [Repository]

    init(repositories: [Repository] = []) {
      self.repositories = repositories
    }

    func fetchAll() async -> [Repository] {
      repositories
    }

    func isFavorite(id: Int) async -> Bool {
      repositories.contains { $0.id == id }
    }

    func add(_ repository: Repository) async {
      repositories.append(repository)
    }

    func remove(id: Int) async {
      repositories.removeAll { $0.id == id }
    }
  }

  actor PreviewTokenStorage: TokenStorageProtocol {
    private var token: String?

    init(token: String? = nil) {
      self.token = token
    }

    func loadToken() async -> String? {
      token
    }

    func saveToken(_ token: String) async throws {
      self.token = token
    }

    func deleteToken() async throws {
      token = nil
    }
  }
#endif

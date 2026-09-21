//
//  DetailView.swift
//  SampleGH
//

import SwiftUI

struct DetailView: View {
  @State private var viewModel: DetailViewModel

  init(
    repository: Repository,
    gitHubService: GitHubServiceProtocol = GitHubService(),
    favoritesStorage: FavoritesStorageProtocol = LocalFavoritesDataSource()
  ) {
    _viewModel = State(
      wrappedValue: DetailViewModel(
        repository: repository, gitHubService: gitHubService, favoritesStorage: favoritesStorage))
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        header
        metrics
        Divider()
        readmeSection
      }
      .padding()
    }
    .navigationTitle(viewModel.repository.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          Task { await viewModel.toggleFavorite() }
        } label: {
          Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
        }
        .accessibilityLabel(viewModel.isFavorite ? "お気に入り解除" : "お気に入り登録")
      }
    }
    .task {
      await viewModel.onAppear()
    }
  }

  private var header: some View {
    HStack(alignment: .top, spacing: 12) {
      ProfileAvatarButton(owner: viewModel.repository.owner, size: 56)

      VStack(alignment: .leading, spacing: 4) {
        Text(viewModel.repository.fullName)
          .font(.title2.bold())

        if let description = viewModel.repository.description {
          Text(description)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        Text("作成日: \(viewModel.repository.createdAt.formatted(date: .abbreviated, time: .omitted))")
          .font(.caption)
          .foregroundStyle(.secondary)
        Text("更新日: \(viewModel.repository.updatedAt.formatted(date: .abbreviated, time: .omitted))")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }

  private var metrics: some View {
    HStack(spacing: 0) {
      metric(value: "\(viewModel.repository.stargazersCount)", label: "Stars", systemImage: "star")
      metric(value: "\(viewModel.repository.forksCount)", label: "Forks", systemImage: "tuningfork")
      metric(
        value: "\(viewModel.repository.openIssuesCount)", label: "Issues",
        systemImage: "exclamationmark.circle")
      metric(
        value: viewModel.repository.license?.name ?? "-", label: "License", systemImage: "doc.text")
    }
  }

  private func metric(value: String, label: String, systemImage: String) -> some View {
    VStack(spacing: 4) {
      Label(value, systemImage: systemImage)
        .font(.subheadline.bold())
        .lineLimit(1)
        .minimumScaleFactor(0.7)
      Text(label)
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  private var readmeSection: some View {
    switch viewModel.readmeState {
    case .loading:
      ProgressView()
        .frame(maxWidth: .infinity)
        .padding(.top, 32)
    case .loaded(let markdown):
      ReadmeView(markdown: markdown)
    case .error(let message):
      ErrorView(message: message) {
        Task { await viewModel.retryReadme() }
      }
    }
  }
}

#if DEBUG
  #Preview {
    NavigationStack {
      DetailView(
        repository: .preview,
        gitHubService: PreviewGitHubService(),
        favoritesStorage: PreviewFavoritesStorage())
    }
  }

  #Preview("README Error") {
    NavigationStack {
      DetailView(
        repository: .preview,
        gitHubService: PreviewGitHubService(error: .invalidResponse),
        favoritesStorage: PreviewFavoritesStorage())
    }
  }
#endif

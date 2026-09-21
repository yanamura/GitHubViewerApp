//
//  DetailView.swift
//  SampleGH
//

import SwiftUI

struct DetailView: View {
  @State private var viewModel: DetailViewModel

  init(repository: Repository) {
    _viewModel = State(wrappedValue: DetailViewModel(repository: repository))
  }

  var body: some View {
    let repository = viewModel.repository
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        DetailHeader(
          owner: repository.owner,
          fullName: repository.fullName,
          description: repository.description,
          createdAt: repository.createdAt,
          updatedAt: repository.updatedAt
        )
        DetailMetrics(
          stargazersCount: repository.stargazersCount,
          forksCount: repository.forksCount,
          openIssuesCount: repository.openIssuesCount,
          licenseName: repository.license?.name
        )
        Divider()
        ReadmeSection(viewModel: viewModel)
      }
      .padding()
    }
    .navigationTitle(repository.name)
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
}

private struct DetailHeader: View {
  let owner: Owner
  let fullName: String
  let description: String?
  let createdAt: Date
  let updatedAt: Date

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      ProfileAvatarButton(owner: owner, size: 56)

      VStack(alignment: .leading, spacing: 4) {
        Text(fullName)
          .font(.title2.bold())

        if let description {
          Text(description)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        Text("作成日: \(createdAt, format: Self.dateStyle)")
          .font(.caption)
          .foregroundStyle(.secondary)
        Text("更新日: \(updatedAt, format: Self.dateStyle)")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }

  private static let dateStyle = Date.FormatStyle(date: .abbreviated, time: .omitted)
}

private struct DetailMetrics: View {
  let stargazersCount: Int
  let forksCount: Int
  let openIssuesCount: Int
  let licenseName: String?

  var body: some View {
    HStack(spacing: 0) {
      MetricItem(value: "\(stargazersCount)", label: "Stars", systemImage: "star")
      MetricItem(value: "\(forksCount)", label: "Forks", systemImage: "tuningfork")
      MetricItem(
        value: "\(openIssuesCount)", label: "Issues", systemImage: "exclamationmark.circle")
      MetricItem(value: licenseName ?? "-", label: "License", systemImage: "doc.text")
    }
  }
}

private struct MetricItem: View {
  let value: String
  let label: LocalizedStringKey
  let systemImage: String

  var body: some View {
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
}

private struct ReadmeSection: View {
  let viewModel: DetailViewModel

  var body: some View {
    switch viewModel.readmeState {
    case .loading:
      ProgressView()
        .frame(maxWidth: .infinity)
        .padding(.top, 32)
    case .loaded(let blocks):
      ReadmeView(blocks: blocks)
    case .error(let message):
      ErrorView(message: message) {
        Task { await viewModel.retryReadme() }
      }
    }
  }
}

#Preview {
  NavigationStack {
    DetailView(
      repository: Repository(
        id: 1,
        name: "swift",
        fullName: "apple/swift",
        owner: Owner(id: 1, login: "apple", avatarURL: nil),
        description: "The Swift Programming Language",
        language: "Swift",
        stargazersCount: 12345,
        forksCount: 678,
        openIssuesCount: 42,
        htmlURL: nil,
        createdAt: Date(timeIntervalSince1970: 0),
        updatedAt: Date(),
        license: License(name: "Apache License 2.0")
      )
    )
  }
}

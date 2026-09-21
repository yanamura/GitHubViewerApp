//
//  FavoritesView.swift
//  SampleGH
//

import SwiftUI

struct FavoritesView: View {
  @State private var viewModel: FavoritesViewModel
  @State private var path = NavigationPath()

  init(favoritesStorage: FavoritesStorageProtocol = LocalFavoritesDataSource()) {
    _viewModel = State(wrappedValue: FavoritesViewModel(favoritesStorage: favoritesStorage))
  }

  var body: some View {
    NavigationStack(path: $path) {
      content
        .navigationTitle("Favorites")
        .navigationDestination(for: Repository.self) { repository in
          DetailView(repository: repository)
        }
    }
    .task {
      await viewModel.onAppear()
    }
    .onChange(of: path) { _, newPath in
      guard newPath.isEmpty else { return }
      Task { await viewModel.onAppear() }
    }
  }

  @ViewBuilder
  private var content: some View {
    if viewModel.repositories.isEmpty {
      ContentUnavailableView(
        "お気に入りはありません", systemImage: "star",
        description: Text("リポジトリ詳細画面から星アイコンをタップして追加できます。"))
    } else {
      List(viewModel.repositories) { repository in
        NavigationLink(value: repository) {
          SearchRow(repository: repository)
        }
        .swipeActions {
          Button(role: .destructive) {
            Task { await viewModel.remove(repository) }
          } label: {
            Label("削除", systemImage: "trash")
          }
        }
      }
      .listStyle(.plain)
    }
  }
}

#if DEBUG
  #Preview("With Favorites") {
    FavoritesView(favoritesStorage: PreviewFavoritesStorage(repositories: Repository.previews))
  }

  #Preview("Empty") {
    FavoritesView(favoritesStorage: PreviewFavoritesStorage())
  }
#endif

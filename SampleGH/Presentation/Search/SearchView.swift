//
//  SearchView.swift
//  SampleGH
//

import SwiftUI

struct SearchView: View {
  @State private var viewModel = SearchViewModel()

  var body: some View {
    NavigationStack {
      SearchContent(viewModel: viewModel)
        .navigationTitle("Search")
        .searchable(text: $viewModel.query, prompt: "Search repositories")
        .onSubmit(of: .search) {
          Task { await viewModel.submitSearch() }
        }
        .task(id: viewModel.query) {
          await viewModel.onQueryChanged()
        }
        .navigationDestination(for: Repository.self) { repository in
          DetailView(repository: repository)
        }
    }
  }
}

private struct SearchContent: View {
  let viewModel: SearchViewModel

  var body: some View {
    switch viewModel.phase {
    case .idle:
      ContentUnavailableView.search
    case .loading:
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    case .loaded:
      if viewModel.repositories.isEmpty {
        ContentUnavailableView.search(text: viewModel.query)
      } else {
        SearchResultList(viewModel: viewModel)
      }
    case .error(let message):
      ErrorView(message: message) {
        Task { await viewModel.retry() }
      }
    }
  }
}

private struct SearchResultList: View {
  let viewModel: SearchViewModel

  var body: some View {
    List(viewModel.repositories) { repository in
      NavigationLink(value: repository) {
        SearchRow(repository: repository)
      }
      .task {
        await viewModel.loadNextPageIfNeeded(currentItem: repository)
      }
    }
    .listStyle(.plain)
    .safeAreaInset(edge: .bottom) {
      if viewModel.isLoadingNextPage {
        ProgressView()
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity)
      }
    }
  }
}

#Preview {
  SearchView()
}

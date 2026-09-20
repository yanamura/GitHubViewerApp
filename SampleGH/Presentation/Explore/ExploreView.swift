//
//  ExploreView.swift
//  SampleGH
//

import SwiftUI

struct ExploreView: View {
  @State private var viewModel = ExploreViewModel()

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        languagePicker
        content
      }
      .navigationTitle("Explore")
      .task(id: viewModel.languageFilter) {
        await viewModel.load()
      }
      .navigationDestination(for: Repository.self) { repository in
        DetailView(repository: repository)
      }
    }
  }

  private var languagePicker: some View {
    Picker("言語", selection: $viewModel.languageFilter) {
      ForEach(ExploreLanguageFilter.allCases) { filter in
        Text(filter.rawValue).tag(filter)
      }
    }
    .pickerStyle(.segmented)
    .padding(.horizontal)
    .padding(.top, 8)
  }

  @ViewBuilder
  private var content: some View {
    switch viewModel.phase {
    case .loading:
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    case .loaded:
      if viewModel.repositories.isEmpty {
        ContentUnavailableView(
          "リポジトリが見つかりません", systemImage: "magnifyingglass",
          description: Text("条件を変更して再度お試しください。"))
      } else {
        resultList
      }
    case .error(let message):
      ErrorView(message: message) {
        Task { await viewModel.retry() }
      }
    }
  }

  private var resultList: some View {
    List(viewModel.repositories) { repository in
      NavigationLink(value: repository) {
        SearchRow(repository: repository)
      }
    }
    .listStyle(.plain)
    .refreshable {
      await viewModel.refresh()
    }
  }
}

#Preview {
  ExploreView()
}

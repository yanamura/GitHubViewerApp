//
//  UserProfileView.swift
//  SampleGH
//

import SwiftUI

struct UserProfileView: View {
  @State private var viewModel: UserProfileViewModel

  init(owner: Owner) {
    _viewModel = State(wrappedValue: UserProfileViewModel(owner: owner))
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        // アバターは Owner から即時に出せるので、ローディング中もレイアウトが変わらない。
        AsyncAvatarView(url: viewModel.owner.avatarURL, size: 96)
        UserProfileContent(viewModel: viewModel)
      }
      .frame(maxWidth: .infinity)
      .padding(.top, 32)
      .padding(.horizontal)
    }
    .presentationDetents([.medium])
    .presentationDragIndicator(.visible)
    .task {
      await viewModel.onAppear()
    }
  }
}

private struct UserProfileContent: View {
  let viewModel: UserProfileViewModel

  var body: some View {
    VStack(spacing: 16) {
      switch viewModel.state {
      case .loading:
        Text(verbatim: "@\(viewModel.owner.login)")
          .foregroundStyle(.secondary)
        ProgressView()
      case .loaded(let profile):
        Text(profile.displayName)
          .font(.title2.bold())
        Text(verbatim: "@\(profile.login)")
          .foregroundStyle(.secondary)
        if let bio = profile.displayBio {
          Text(bio)
            .multilineTextAlignment(.center)
        }
      case .error(let message):
        ErrorView(message: message) {
          Task { await viewModel.retry() }
        }
      }
    }
  }
}

#Preview {
  UserProfileView(owner: Owner(id: 1, login: "apple", avatarURL: nil))
}

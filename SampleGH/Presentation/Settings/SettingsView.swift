//
//  SettingsView.swift
//  SampleGH
//

import SwiftUI

struct SettingsView: View {
  @State private var viewModel: SettingsViewModel

  init(
    tokenStorage: TokenStorageProtocol = KeychainManager(),
    gitHubService: GitHubServiceProtocol = GitHubService()
  ) {
    _viewModel = State(
      wrappedValue: SettingsViewModel(tokenStorage: tokenStorage, gitHubService: gitHubService))
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          SecureField("ghp_xxxxxxxx", text: $viewModel.tokenInput)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

          Button {
            Task { await viewModel.save() }
          } label: {
            HStack {
              Text("保存")
              if viewModel.isSaving {
                Spacer()
                ProgressView()
              }
            }
          }
          .disabled(!viewModel.canSave)

          if viewModel.hasSavedToken {
            Button("トークンを削除", role: .destructive) {
              Task { await viewModel.delete() }
            }
            .disabled(viewModel.isSaving)
          }
        } header: {
          Text("Personal Access Token")
        } footer: {
          footer
        }
      }
      .navigationTitle("Settings")
      .task {
        await viewModel.onAppear()
      }
    }
  }

  @ViewBuilder
  private var footer: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("トークンを登録するとGitHub APIのレート制限が緩和されます。トークンは端末のKeychainに保存されます。")
      switch viewModel.status {
      case .success(let message):
        Label(message, systemImage: "checkmark.circle")
          .foregroundStyle(.green)
      case .failure(let message):
        Label(message, systemImage: "exclamationmark.triangle")
          .foregroundStyle(.red)
      case nil:
        EmptyView()
      }
    }
  }
}

#if DEBUG
  #Preview("No Token") {
    SettingsView(tokenStorage: PreviewTokenStorage(), gitHubService: PreviewGitHubService())
  }

  #Preview("Saved Token") {
    SettingsView(
      tokenStorage: PreviewTokenStorage(token: "ghp_preview"),
      gitHubService: PreviewGitHubService())
  }
#endif

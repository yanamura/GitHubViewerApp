//
//  SettingsView.swift
//  SampleGH
//

import SwiftUI

struct SettingsView: View {
  @State private var viewModel = SettingsViewModel()

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
          TokenFooter(status: viewModel.status)
        }
      }
      .navigationTitle("Settings")
      .task {
        await viewModel.onAppear()
      }
    }
  }
}

private struct TokenFooter: View {
  let status: SettingsViewModel.Status?

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("トークンを登録するとGitHub APIのレート制限が緩和されます。トークンは端末のKeychainに保存されます。")
      switch status {
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

#Preview {
  SettingsView()
}

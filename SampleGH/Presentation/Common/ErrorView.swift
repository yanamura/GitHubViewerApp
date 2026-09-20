//
//  ErrorView.swift
//  SampleGH
//

import SwiftUI

struct ErrorView: View {
  let message: String
  let retryAction: () -> Void

  var body: some View {
    ContentUnavailableView {
      Label("エラーが発生しました", systemImage: "exclamationmark.triangle")
    } description: {
      Text(message)
    } actions: {
      Button("再試行", action: retryAction)
    }
  }
}

#Preview {
  ErrorView(message: "通信エラーが発生しました。") {}
}

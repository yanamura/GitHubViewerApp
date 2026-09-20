//
//  AsyncAvatarView.swift
//  SampleGH
//

import SwiftUI

struct AsyncAvatarView: View {
  let url: URL?
  var size: CGFloat = 40

  var body: some View {
    AsyncImage(url: url) { phase in
      if let image = phase.image {
        image
          .resizable()
          .scaledToFill()
      } else {
        placeholder
      }
    }
    .frame(width: size, height: size)
    .clipShape(Circle())
  }

  private var placeholder: some View {
    Circle()
      .fill(.secondary.opacity(0.2))
      .overlay {
        Image(systemName: "person.fill")
          .foregroundStyle(.secondary)
      }
  }
}

#Preview {
  AsyncAvatarView(url: nil)
}

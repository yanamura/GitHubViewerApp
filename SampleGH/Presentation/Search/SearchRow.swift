//
//  SearchRow.swift
//  SampleGH
//

import SwiftUI

struct SearchRow: View {
  let repository: Repository

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      AsyncAvatarView(url: repository.owner.avatarURL)

      VStack(alignment: .leading, spacing: 4) {
        Text(repository.fullName)
          .font(.headline)
          .lineLimit(1)

        if let description = repository.description {
          Text(description)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineLimit(2)
        }

        HStack(spacing: 12) {
          if let language = repository.language {
            Text(language)
          }
          Label("\(repository.stargazersCount)", systemImage: "star")
          Label("\(repository.forksCount)", systemImage: "tuningfork")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  SearchRow(
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
      license: nil
    )
  )
}

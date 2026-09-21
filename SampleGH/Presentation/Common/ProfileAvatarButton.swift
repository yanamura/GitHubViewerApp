//
//  ProfileAvatarButton.swift
//  SampleGH
//

import SwiftUI

/// タップするとオーナーのプロフィールをハーフモーダルで表示するアバター。
struct ProfileAvatarButton: View {
  let owner: Owner
  var size: CGFloat = 40

  @State private var isPresented = false

  var body: some View {
    Button {
      isPresented = true
    } label: {
      AsyncAvatarView(url: owner.avatarURL, size: size)
    }
    // Listの行内でも、行全体のタップ（NavigationLink遷移）と切り離してアバターだけで反応させる。
    .buttonStyle(.plain)
    .contentShape(Circle())
    .accessibilityLabel("\(owner.login)のプロフィールを表示")
    .sheet(isPresented: $isPresented) {
      UserProfileView(owner: owner)
    }
  }
}

#Preview {
  ProfileAvatarButton(owner: Owner(id: 1, login: "apple", avatarURL: nil))
}

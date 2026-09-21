//
//  UserProfileTests.swift
//  SampleGHTests
//

import Foundation
import Testing

@testable import SampleGH

@MainActor
struct UserProfileTests {
  private static func makeProfile(name: String?, bio: String?) -> UserProfile {
    UserProfile(id: 1, login: "octocat", name: name, bio: bio)
  }

  @Test func decodingMapsFieldsFromJSON() throws {
    let json = """
      {
          "id": 583231,
          "login": "octocat",
          "avatar_url": "https://example.com/avatar.png",
          "name": "The Octocat",
          "bio": "Hello, world!",
          "followers": 100
      }
      """.data(using: .utf8)!

    let profile = try JSONDecoder().decode(UserProfile.self, from: json)

    #expect(profile.id == 583231)
    #expect(profile.login == "octocat")
    #expect(profile.name == "The Octocat")
    #expect(profile.bio == "Hello, world!")
  }

  @Test func decodingHandlesNullNameAndBio() throws {
    let json = """
      { "id": 1, "login": "octocat", "name": null, "bio": null }
      """.data(using: .utf8)!

    let profile = try JSONDecoder().decode(UserProfile.self, from: json)

    #expect(profile.name == nil)
    #expect(profile.bio == nil)
  }

  @Test func decodingHandlesMissingNameAndBio() throws {
    let json = """
      { "id": 1, "login": "octocat" }
      """.data(using: .utf8)!

    let profile = try JSONDecoder().decode(UserProfile.self, from: json)

    #expect(profile.name == nil)
    #expect(profile.bio == nil)
  }

  @Test func displayNameReturnsNameWhenPresent() {
    let profile = Self.makeProfile(name: "The Octocat", bio: nil)

    #expect(profile.displayName == "The Octocat")
  }

  @Test(arguments: [nil, "", "   ", "\n"])
  func displayNameFallsBackToLoginWhenNameIsNilOrBlank(name: String?) {
    let profile = Self.makeProfile(name: name, bio: nil)

    #expect(profile.displayName == "octocat")
  }

  @Test func displayBioReturnsTrimmedBio() {
    let profile = Self.makeProfile(name: nil, bio: "  Hello, world!\n")

    #expect(profile.displayBio == "Hello, world!")
  }

  @Test(arguments: [nil, "", "   ", "\n"])
  func displayBioIsNilWhenBioIsNilOrBlank(bio: String?) {
    let profile = Self.makeProfile(name: nil, bio: bio)

    #expect(profile.displayBio == nil)
  }
}

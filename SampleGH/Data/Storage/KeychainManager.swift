//
//  KeychainManager.swift
//  SampleGH
//

import Foundation
import Security

struct KeychainError: Error, Equatable, Sendable {
  let status: OSStatus
}

/// Keychainへのアクセスを抑えるため、読み込んだトークンをメモリにキャッシュする。
/// キャッシュを共有できるよう、アプリでは`DependencyValues.tokenStorage`経由で単一インスタンスを使う。
actor KeychainManager: TokenStorageProtocol {
  private let service: String
  private let account: String
  private var isCacheLoaded = false
  private var cachedToken: String?

  init(service: String = "com.samplegh.github", account: String = "personal-access-token") {
    self.service = service
    self.account = account
  }

  func loadToken() async -> String? {
    if isCacheLoaded { return cachedToken }
    cachedToken = readTokenFromKeychain()
    isCacheLoaded = true
    return cachedToken
  }

  func saveToken(_ token: String) async throws {
    try writeTokenToKeychain(token)
    cachedToken = token
    isCacheLoaded = true
  }

  func deleteToken() async throws {
    let status = SecItemDelete(baseQuery as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw KeychainError(status: status)
    }
    cachedToken = nil
    isCacheLoaded = true
  }

  private func readTokenFromKeychain() -> String? {
    var query = baseQuery
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne

    var result: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    guard status == errSecSuccess, let data = result as? Data else { return nil }
    return String(data: data, encoding: .utf8)
  }

  private func writeTokenToKeychain(_ token: String) throws {
    let data = Data(token.utf8)
    let attributes: [String: Any] = [kSecValueData as String: data]

    let updateStatus = SecItemUpdate(baseQuery as CFDictionary, attributes as CFDictionary)
    switch updateStatus {
    case errSecSuccess:
      return
    case errSecItemNotFound:
      var addQuery = baseQuery
      addQuery[kSecValueData as String] = data
      addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
      let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
      guard addStatus == errSecSuccess else { throw KeychainError(status: addStatus) }
    default:
      throw KeychainError(status: updateStatus)
    }
  }

  private var baseQuery: [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
  }
}

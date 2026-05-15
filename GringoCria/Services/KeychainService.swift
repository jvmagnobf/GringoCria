//
//  KeychainService.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import Foundation
import Security

// MARK: - KeychainKey

enum KeychainKey {
    static let userIdentifier = "com.gringocria.userIdentifier"
    static let fullName       = "com.gringocria.fullName"
}

// MARK: - UserDefaultsKey

enum UserDefaultsKey {
    static let userNickname            = "userNickname"
    static let completedSubscenarioIDs = "completedSubscenarioIDs"
    static let authSource              = "authSource"
    static let hasCompletedProfileSetup = "hasCompletedProfileSetup"
}

// MARK: - KeychainService

struct KeychainService {
    static func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String:   data
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            print("[Keychain] Erro ao salvar '\(key)': \(status)")
        }
    }

    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data  = result as? Data,
              let value = String(data: data, encoding: .utf8)
        else { return nil }

        return value
    }
}

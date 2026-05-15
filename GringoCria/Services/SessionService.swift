//
//  SessionService.swift
//  GringoCria
//
//  Created by OpenAI Codex on 12/05/26.
//

import Foundation

// MARK: - SessionSource

enum SessionSource: String {
    case apple
    case guest
}

// MARK: - SessionService

struct SessionService {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func resolveAuthState() -> AuthState {
        guard currentSessionSource() != nil else {
            return .unauthenticated
        }

        return hasCompletedProfileSetup() ? .authenticated : .firstAccess
    }

    func startGuestSession() {
        setSessionSource(.guest)
        setProfileSetupCompleted(false)
    }

    func startAppleSession(userIdentifier: String, fullName: String?) {
        let isFirstSession = KeychainService.load(key: KeychainKey.userIdentifier) == nil

        KeychainService.save(key: KeychainKey.userIdentifier, value: userIdentifier)

        if let fullName, !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            KeychainService.save(key: KeychainKey.fullName, value: fullName)
        }

        setSessionSource(.apple)

        if isFirstSession {
            setProfileSetupCompleted(false)
        }
    }

    func markProfileSetupCompleted() {
        setProfileSetupCompleted(true)
    }

    func currentSessionSource() -> SessionSource? {
        if let rawValue = userDefaults.string(forKey: UserDefaultsKey.authSource),
           let source = SessionSource(rawValue: rawValue) {
            return source
        }

        if KeychainService.load(key: KeychainKey.userIdentifier) != nil {
            return .apple
        }

        return nil
    }

    func hasCompletedProfileSetup() -> Bool {
        userDefaults.bool(forKey: UserDefaultsKey.hasCompletedProfileSetup)
    }

    // MARK: - Private

    private func setSessionSource(_ source: SessionSource) {
        userDefaults.set(source.rawValue, forKey: UserDefaultsKey.authSource)
    }

    private func setProfileSetupCompleted(_ isCompleted: Bool) {
        userDefaults.set(isCompleted, forKey: UserDefaultsKey.hasCompletedProfileSetup)
    }
}

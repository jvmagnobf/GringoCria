//
//  ProfileService.swift
//  GringoCria
//
//  Created by João Victor Magno on 12/05/26.
//

import Foundation
import UIKit

// MARK: - ProfileService

struct ProfileService {
    static let defaultNickname = "Traveler"

    private let userDefaults: UserDefaults
    private let profileImageStore: ProfileImageStore
    private let nicknameMaxLength = 20

    init(
        userDefaults: UserDefaults = .standard,
        profileImageStore: ProfileImageStore = ProfileImageStore()
    ) {
        self.userDefaults = userDefaults
        self.profileImageStore = profileImageStore
    }

    // MARK: - Nickname

    func loadNickname() -> String {
        if let savedNickname = userDefaults.string(forKey: UserDefaultsKey.userNickname),
           !savedNickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return savedNickname
        }

        if let fullName = KeychainService.load(key: KeychainKey.fullName),
           !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return fullName
        }

        return Self.defaultNickname
    }

    func limitedNickname(_ nickname: String) -> String {
        guard nickname.count > nicknameMaxLength else { return nickname }
        return String(nickname.prefix(nicknameMaxLength))
    }

    func nicknameValidationError(for nickname: String) -> String? {
        let allowedCharacters = CharacterSet.letters
            .union(.decimalDigits)
            .union(CharacterSet(charactersIn: " _-’."))

        let isValid = nickname.unicodeScalars.allSatisfy {
            allowedCharacters.contains($0)
        }

        return isValid ? nil : "Only letters, numbers, spaces, _, -, ' and . allowed"
    }

    @discardableResult
    func saveNickname(_ nickname: String) -> String {
        let finalNickname = normalizedNickname(nickname)
        userDefaults.set(finalNickname, forKey: UserDefaultsKey.userNickname)
        return finalNickname
    }

    // MARK: - Profile Photo

    func loadProfilePhoto() async -> UIImage? {
        guard let data = await profileImageStore.loadImageData() else { return nil }
        return UIImage(data: data)
    }

    func saveProfilePhoto(_ image: UIImage) async {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        await profileImageStore.saveImageData(data)
    }

    // MARK: - Private

    private func normalizedNickname(_ nickname: String) -> String {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedNickname.isEmpty ? Self.defaultNickname : trimmedNickname
    }
}

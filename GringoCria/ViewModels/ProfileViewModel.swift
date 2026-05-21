//
//  ProfileViewModel.swift
//  GringoCria
//
//  Created by João Victor Magno on 12/05/26.
//

import Foundation
import UIKit

// MARK: - ProfileViewModel

@Observable
@MainActor
final class ProfileViewModel {
    private(set) var profileImage: UIImage?
    var nickname: String
    private(set) var nicknameError: String?
    private(set) var hasChanges = false
    private(set) var isSaving: Bool = false
    private(set) var statusMessage: String?
    private(set) var totalScenarios: Int = 0

    private let profileService: ProfileService
    private var savedNickname: String
    private var savedProfileImage: UIImage?
    private var hasProfilePhotoChanges = false
    private var hasLoadedProfilePhoto = false

    convenience init() {
        self.init(profileService: ProfileService())
    }

    init(profileService: ProfileService) {
        let loadedNickname = profileService.loadNickname()

        self.profileService = profileService
        self.savedNickname = loadedNickname
        self.nickname = loadedNickname
    }

    // MARK: - Public

    func loadProfilePhoto() async {
        guard !hasLoadedProfilePhoto else { return }
        hasLoadedProfilePhoto = true

        let loadedProfileImage = await profileService.loadProfilePhoto()
        profileImage = loadedProfileImage
        savedProfileImage = loadedProfileImage
        updateChangeState()
    }

    func validateNickname() {
        let limitedNickname = profileService.limitedNickname(nickname)
        if limitedNickname != nickname {
            nickname = limitedNickname
        }

        nicknameError = profileService.nicknameValidationError(for: nickname)
        statusMessage = nil
        updateChangeState()
    }

    func updateProfilePhoto(_ image: UIImage) {
        profileImage = image
        hasProfilePhotoChanges = true
        statusMessage = nil
        updateChangeState()
    }

    func saveChanges() async {
        isSaving = true
        defer { isSaving = false }

        validateNickname()
        guard nicknameError == nil else { return }

        let finalNickname = profileService.saveNickname(nickname)

        if hasProfilePhotoChanges, let profileImage {
            await profileService.saveProfilePhoto(profileImage)
        }

        nickname = finalNickname
        savedNickname = finalNickname
        savedProfileImage = profileImage
        hasProfilePhotoChanges = false
        hasChanges = false
        statusMessage = "Profile updated"
    }

    func loadStats() async {
        guard let url = Bundle.main.url(forResource: "scenarios", withExtension: "json"),
              let data = try? await Task.detached(priority: .utility, operation: { try Data(contentsOf: url) }).value,
              let scenarios = try? JSONDecoder().decode([Scenario].self, from: data)
        else { return }

        totalScenarios = scenarios
            .flatMap { $0.subscenarios }
            .filter { !$0.isLocked }
            .count
    }

    func cancelChanges() {
        nickname = savedNickname
        profileImage = savedProfileImage
        nicknameError = nil
        statusMessage = nil
        hasProfilePhotoChanges = false
        hasChanges = false
    }

    // MARK: - Private

    private func updateChangeState() {
        hasChanges = nickname != savedNickname || hasProfilePhotoChanges
    }
}

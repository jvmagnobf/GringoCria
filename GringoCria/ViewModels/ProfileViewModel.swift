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
    private let progressService: ProgressService
    private var savedNickname: String
    private var savedProfileImage: UIImage?
    private var hasProfilePhotoChanges = false
    private var hasLoadedProfilePhoto = false

    var completedCount: Int { progressService.completedIDs.count }

    init(
        profileService: ProfileService = ProfileService(),
        progressService: ProgressService
    ) {
        let loadedNickname = profileService.loadNickname()

        self.profileService = profileService
        self.progressService = progressService
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
        let result = profileService.validateAndLimit(nickname)
        nickname = result.validated
        nicknameError = result.error
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

    func loadTotalScenarios() async {
        let scenarios = await ScenarioRepository.load()
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

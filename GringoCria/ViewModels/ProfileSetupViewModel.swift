//
//  ProfileSetupViewModel.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import Foundation
import UIKit

// MARK: - ProfileSetupViewModel

@Observable
@MainActor
final class ProfileSetupViewModel {
    private(set) var profileImage: UIImage?
    var nickname: String = ""
    private(set) var nicknameError: String?

    var onSetupCompleted: (() -> Void)?

    private let profileService: ProfileService
    private let sessionService: SessionService
    private var hasLoadedProfilePhoto = false

    convenience init() {
        self.init(
            profileService: ProfileService(),
            sessionService: SessionService()
        )
    }

    init(
        profileService: ProfileService,
        sessionService: SessionService
    ) {
        self.profileService = profileService
        self.sessionService = sessionService
        self.nickname = profileService.loadNickname()
    }

    // MARK: - Public

    func loadProfilePhoto() async {
        guard !hasLoadedProfilePhoto else { return }
        hasLoadedProfilePhoto = true
        profileImage = await profileService.loadProfilePhoto()
    }

    func validateNickname() {
        let limitedNickname = profileService.limitedNickname(nickname)
        if limitedNickname != nickname {
            nickname = limitedNickname
        }

        nicknameError = profileService.nicknameValidationError(for: nickname)
    }

    func updateProfilePhoto(_ image: UIImage) async {
        profileImage = image
        await profileService.saveProfilePhoto(image)
    }

    func saveDone() {
        // TODO: avaliar moderação de conteúdo no nickname
        validateNickname()
        guard nicknameError == nil else { return }

        nickname = profileService.saveNickname(nickname)
        sessionService.markProfileSetupCompleted()
        onSetupCompleted?()
    }
}

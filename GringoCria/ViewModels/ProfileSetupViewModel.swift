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

    private(set) var setupCompleted: Bool = false

    private let profileService: ProfileService
    private let sessionService: SessionService
    private var hasLoadedProfilePhoto = false

    init(
        profileService: ProfileService? = nil,
        sessionService: SessionService? = nil
    ) {
        // Services instanciados dentro do init @MainActor para evitar avaliação
        // de default em contexto nonisolated (Swift 6.2 strict concurrency).
        let resolvedProfileService = profileService ?? ProfileService()
        self.profileService = resolvedProfileService
        self.sessionService = sessionService ?? SessionService()
        self.nickname = resolvedProfileService.loadNickname()
    }

    // MARK: - Public

    func loadProfilePhoto() async {
        guard !hasLoadedProfilePhoto else { return }
        hasLoadedProfilePhoto = true
        profileImage = await profileService.loadProfilePhoto()
    }

    func validateNickname() {
        let result = profileService.validateAndLimit(nickname)
        nickname = result.validated
        nicknameError = result.error
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
        setupCompleted = true
    }
}

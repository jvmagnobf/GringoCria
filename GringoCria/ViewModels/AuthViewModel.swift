//
//  AuthViewModel.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import Foundation
import AuthenticationServices

// MARK: - AuthViewModel

@Observable
@MainActor
final class AuthViewModel {
    var errorMessage: String?

    private let appState: AppState
    private let sessionService: SessionService

    convenience init(appState: AppState) {
        self.init(appState: appState, sessionService: SessionService())
    }

    init(
        appState: AppState,
        sessionService: SessionService
    ) {
        self.appState = appState
        self.sessionService = sessionService
    }

    // MARK: - Public

    func continueAsGuest() {
        sessionService.startGuestSession()
        appState.restoreSession()
    }

    func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential
            else { return }

            let userIdentifier = credential.user
            let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")

            handleSuccessfulSignIn(
                userIdentifier: userIdentifier,
                fullName: fullName.isEmpty ? nil : fullName
            )

        case .failure(let error):
            errorMessage = error.localizedDescription
            print("[AuthViewModel] Erro no Sign In with Apple: \(error)")
        }
    }

    // MARK: - Private

    private func handleSuccessfulSignIn(userIdentifier: String, fullName: String?) {
        sessionService.startAppleSession(
            userIdentifier: userIdentifier,
            fullName: fullName
        )

        // TODO: migração de progresso guest → conta

        appState.restoreSession()
    }
}

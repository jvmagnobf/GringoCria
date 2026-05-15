//
//  AppState.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import Foundation
import Observation

// MARK: - AuthState

enum AuthState {
    case unauthenticated
    case firstAccess
    case authenticated
}

// MARK: - AppState

@Observable
final class AppState {
    var authState: AuthState

    private let sessionService: SessionService

    init(sessionService: SessionService = SessionService()) {
        self.sessionService = sessionService
        self.authState = sessionService.resolveAuthState()
    }

    func restoreSession() {
        authState = sessionService.resolveAuthState()
    }
}

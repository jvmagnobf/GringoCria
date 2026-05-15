//
//  AppRouter.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI

// MARK: - AppRouter

struct AppRouter: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        switch appState.authState {
        case .unauthenticated:
            AuthView()
        case .firstAccess:
            ProfileSetupView()
        case .authenticated:
            AuthenticatedTabView()
        }
    }
}

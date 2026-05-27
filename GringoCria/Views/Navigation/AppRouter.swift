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
    @State private var showingSplash = true

    var body: some View {
        if showingSplash {
            SplashView {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showingSplash = false
                }
            }
        } else {
            switch appState.authState {
            case .unauthenticated:
                ProfileSetupView()
            case .firstAccess:
                ProfileSetupView()
            case .authenticated:
                AuthenticatedTabView()
            }
        }
    }
}

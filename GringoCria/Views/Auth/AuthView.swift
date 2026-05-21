//
//  AuthView.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//
//  IMPORTANTE: Ative a capability "Sign In with Apple" no Xcode:
//  Target → Signing & Capabilities → "+ Capability" → Sign In with Apple

import SwiftUI
import AuthenticationServices

// MARK: - AuthView

struct AuthView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: AuthViewModel?

    var body: some View {
        ZStack {
            Image("menu_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Text("GringoCria")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("Practice Portuguese for real life")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                authActionsContent
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = AuthViewModel(appState: appState)
            }
        }
    }

    // MARK: - Auth Actions

    @ViewBuilder
    private var authActionsContent: some View {
        if let viewModel {
            VStack(spacing: 16) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    // onCompletion é chamado em thread arbitrária — despachamos
                    // para o MainActor antes de tocar em qualquer propriedade
                    // do viewModel (@MainActor @Observable).
                    Task { @MainActor in
                        viewModel.handleSignInResult(result)
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)

                Button("Continue without account") {
                    viewModel.continueAsGuest()
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
            }
        }
    }
}

#Preview {
    NavigationStack {
        AuthView()
    }
    .environment(AppState())
}

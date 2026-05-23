//
//  ProfileSetupView.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.

import SwiftUI

// MARK: - ProfileSetupView

struct ProfileSetupView: View {
    @Environment(AppState.self) private var appState

    @State private var viewModel = ProfileSetupViewModel()

    // MARK: - Body

    var body: some View {
        ZStack {
            Image("menu_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Text("Set up your profile")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                profilePhotoSection

                nicknameSection

                Spacer()

                doneButton
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
        }
        .onChange(of: viewModel.setupCompleted) { _, completed in
            if completed { appState.restoreSession() }
        }
        .task {
            await viewModel.loadProfilePhoto()
        }
    }

    // MARK: - Subviews

    private var profilePhotoSection: some View {
        ProfilePhotoField(
            image: viewModel.profileImage,
            size: 100,
            placeholderSystemName: "person.circle",
            actionTitle: nil,
            accessibilityLabel: "Change profile photo"
        ) { image in
            Task { await viewModel.updateProfilePhoto(image) }
        }
    }

    private var nicknameSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField(
                "",
                text: $viewModel.nickname,
                prompt: Text("How do you want to be called?")
                    .foregroundStyle(Color("mensagem_fonte").opacity(0.6))
            )
            .foregroundStyle(Color("mensagem_fonte"))
            .textFieldStyle(.plain)
            .autocorrectionDisabled()
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.white.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 14))
                .onChange(of: viewModel.nickname) {
                    viewModel.validateNickname()
                }

            if let error = viewModel.nicknameError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var doneButton: some View {
        Button("Done") {
            viewModel.saveDone()
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.nicknameError != nil)
    }
}

#Preview {
    NavigationStack {
        ProfileSetupView()
    }
    .environment(AppState())
}

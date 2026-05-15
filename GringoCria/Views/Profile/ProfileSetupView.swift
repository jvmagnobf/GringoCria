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
        VStack(spacing: 32) {
            Text("Set up your profile")
                .font(.title2)
                .fontWeight(.semibold)

            profilePhotoSection

            nicknameSection

            Spacer()

            doneButton
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .onAppear {
            viewModel.onSetupCompleted = {
                appState.restoreSession()
            }
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
            TextField("How do you want to be called?", text: $viewModel.nickname)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
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

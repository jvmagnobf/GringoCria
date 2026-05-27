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

            LinearGradient(
                colors: [.black.opacity(0.55), .black.opacity(0.25), .black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                    .padding(.top, 48)
                    .padding(.horizontal, 32)

                Spacer(minLength: 24)

                profileCard
                    .padding(.horizontal, 24)

                Spacer()

                doneButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
        .onChange(of: viewModel.setupCompleted) { _, completed in
            if completed { appState.restoreSession() }
        }
        .task {
            await viewModel.loadProfilePhoto()
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("What should we call you?")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("This is how cariocas will know you in the conversations.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
        }
    }

    private var profileCard: some View {
        VStack(spacing: 24) {
            ProfilePhotoField(
                image: viewModel.profileImage,
                size: 140,
                placeholderSystemName: "person.circle",
                actionTitle: nil,
                accessibilityLabel: "Change profile photo"
            ) { image in
                Task { await viewModel.updateProfilePhoto(image) }
            }

            nicknameSection
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .glassEffect(in: RoundedRectangle(cornerRadius: 24))
    }

    private var nicknameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(
                "",
                text: $viewModel.nickname,
                prompt: Text("Your name")
                    .foregroundStyle(.white.opacity(0.5))
            )
            .font(.body)
            .foregroundStyle(.white)
            .textFieldStyle(.plain)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            }
            .onChange(of: viewModel.nickname) {
                viewModel.validateNickname()
            }

            if let error = viewModel.nicknameError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.9))
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.nicknameError)
    }

    private var doneButton: some View {
        Button {
            viewModel.saveDone()
        } label: {
            Text("Continue")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isDoneEnabled ? Color.green : Color.white.opacity(0.15))
                }
        }
        .buttonStyle(.plain)
        .disabled(!isDoneEnabled)
        .animation(.easeInOut(duration: 0.2), value: isDoneEnabled)
    }

    private var isDoneEnabled: Bool {
        viewModel.nicknameError == nil && !viewModel.nickname.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

#Preview {
    NavigationStack {
        ProfileSetupView()
    }
    .environment(AppState())
}

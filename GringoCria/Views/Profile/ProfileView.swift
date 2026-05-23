//
//  ProfileView.swift
//  GringoCria
//
//  Created by João Victor Magno on 12/05/26.
//

import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel?
    @Environment(ProgressService.self) private var progressService
    @State private var showingOnboarding = false

    var body: some View {
        Group {
            if let viewModel {
                profileForm(viewModel: viewModel)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = ProfileViewModel(progressService: progressService)
            }
            await viewModel?.loadProfilePhoto()
            await viewModel?.loadTotalScenarios()
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView {
                showingOnboarding = false
            }
        }
    }

    // MARK: - Profile Form

    private func profileForm(viewModel: ProfileViewModel) -> some View {
        Form {
            photoSection(viewModel: viewModel)
            nicknameSection(viewModel: viewModel)
            statsSection(viewModel: viewModel)
            actionButtonsSection(viewModel: viewModel)
        }
        .scrollContentBackground(.hidden)
        .background {
            Image("menu_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private func photoSection(viewModel: ProfileViewModel) -> some View {
        Section {
            ProfilePhotoField(
                image: viewModel.profileImage,
                size: 112,
                placeholderSystemName: "person.crop.circle.fill",
                actionTitle: viewModel.profileImage == nil ? "Add Photo" : "Change Photo",
                accessibilityLabel: "Change profile photo"
            ) { image in
                viewModel.updateProfilePhoto(image)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }

    private func nicknameSection(viewModel: ProfileViewModel) -> some View {
        Section {
            TextField("Nickname", text: Bindable(viewModel).nickname)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .onChange(of: viewModel.nickname) {
                    viewModel.validateNickname()
                }

            if let error = viewModel.nicknameError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Profile Details")
                .foregroundStyle(.white)
        }
    }

    private func statsSection(viewModel: ProfileViewModel) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Scenarios completed")
                    Spacer()
                    Text("\(viewModel.completedCount) / \(viewModel.totalScenarios)")
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }

                if viewModel.totalScenarios > 0 {
                    ProgressView(
                        value: Double(viewModel.completedCount),
                        total: Double(viewModel.totalScenarios)
                    )
                    .tint(.blue)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Progress")
                .foregroundStyle(.white)
        }
    }

    private func actionButtonsSection(viewModel: ProfileViewModel) -> some View {
        Section {
            VStack(spacing: 10) {
                if let statusMessage = viewModel.statusMessage {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Button("Save Changes") {
                    Task { await viewModel.saveChanges() }
                }
                .disabled(!viewModel.hasChanges || viewModel.nicknameError != nil || viewModel.isSaving)
                .buttonStyle(NavyGlassButtonStyle())

                Button("Cancel") {
                    viewModel.cancelChanges()
                }
                .disabled(!viewModel.hasChanges)
                .buttonStyle(NavyGlassButtonStyle())

                Button("Watch Introduction") {
                    showingOnboarding = true
                }
                .buttonStyle(NavyGlassButtonStyle())
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
    }
}

// MARK: - NavyGlassButtonStyle

private struct NavyGlassButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .glassEffect(in: RoundedRectangle(cornerRadius: 12))
            .opacity(isEnabled ? (configuration.isPressed ? 0.7 : 1.0) : 0.4)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environment(ProgressService())
}

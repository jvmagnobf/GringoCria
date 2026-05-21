//
//  ProfileView.swift
//  GringoCria
//
//  Created by João Victor Magno on 12/05/26.
//

import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @Environment(ProgressService.self) private var progressService
    @State private var showingOnboarding = false

    init() {
        _viewModel = State(initialValue: ProfileViewModel())
    }

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            photoSection
            nicknameSection
            statsSection
            actionButtonsSection
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
        .task {
            await viewModel.loadProfilePhoto()
            await viewModel.loadStats()
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView {
                showingOnboarding = false
            }
        }
    }

    // MARK: - Sections

    private var photoSection: some View {
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

    private var nicknameSection: some View {
        Section {
            TextField("Nickname", text: $viewModel.nickname)
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

    private var statsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Scenarios completed")
                    Spacer()
                    Text("\(progressService.completedIDs.count) / \(viewModel.totalScenarios)")
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }

                if viewModel.totalScenarios > 0 {
                    ProgressView(
                        value: Double(progressService.completedIDs.count),
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

    private var actionButtonsSection: some View {
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
}

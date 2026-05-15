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

    init() {
        _viewModel = State(initialValue: ProfileViewModel())
    }

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        Form {
            photoSection
            nicknameSection
            actionsSection
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadProfilePhoto()
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
        Section("Profile Details") {
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
        }
    }

    private var actionsSection: some View {
        Section {
            Button("Save Changes") {
                Task { await viewModel.saveChanges() }
            }
            .disabled(!viewModel.hasChanges || viewModel.nicknameError != nil || viewModel.isSaving)

            Button("Cancel", role: .cancel) {
                viewModel.cancelChanges()
            }
            .disabled(!viewModel.hasChanges)

            if let statusMessage = viewModel.statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}

//
//  ProfilePhotoField.swift
//  GringoCria
//
//  Created by Codex on 12/05/26.
//

import SwiftUI
import PhotosUI
import UIKit

// MARK: - ProfilePhotoField

struct ProfilePhotoField: View {
    let image: UIImage?
    let size: CGFloat
    let placeholderSystemName: String
    let actionTitle: String?
    let accessibilityLabel: String
    let onImageSelected: (UIImage) -> Void

    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showSourceDialog = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false

    var body: some View {
        Button {
            showSourceDialog = true
        } label: {
            ProfilePhotoPreview(
                image: image,
                size: size,
                placeholderSystemName: placeholderSystemName
            )
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 2))
                    .offset(x: 2, y: 2)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .photosPicker(
            isPresented: $showPhotosPicker,
            selection: $photosPickerItem,
            matching: .images
        )
        .fullScreenCover(isPresented: $showCamera) {
            CameraPickerView(selectedImage: Binding(
                get: { image },
                set: { selectedImage in
                    if let selectedImage {
                        onImageSelected(selectedImage)
                    }
                }
            ))
        }
        .confirmationDialog("Choose photo source", isPresented: $showSourceDialog) {
            Button("Photo Library") { showPhotosPicker = true }

            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Camera") { showCamera = true }
            }

            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: photosPickerItem) {
            Task { await loadSelectedPhoto() }
        }
    }

    // MARK: - Private

    @MainActor
    private func loadSelectedPhoto() async {
        guard let item = photosPickerItem else { return }
        defer { photosPickerItem = nil }

        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data)
        else { return }

        onImageSelected(image)
    }
}

// MARK: - ProfilePhotoPreview

private struct ProfilePhotoPreview: View {
    let image: UIImage?
    let size: CGFloat
    let placeholderSystemName: String

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: placeholderSystemName)
                    .resizable()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 1))
    }
}

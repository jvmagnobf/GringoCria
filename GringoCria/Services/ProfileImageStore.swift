//
//  ProfileImageStore.swift
//  GringoCria
//
//  Created by OpenAI Codex on 12/05/26.
//

import Foundation

// MARK: - ProfileImageStore

actor ProfileImageStore {
    private let fileManager: FileManager
    private let profilePhotoFileName: String

    init(
        fileManager: FileManager = .default,
        profilePhotoFileName: String = "profile_photo.jpg"
    ) {
        self.fileManager = fileManager
        self.profilePhotoFileName = profilePhotoFileName
    }

    func loadImageData() -> Data? {
        guard let url = profilePhotoURL() else { return nil }
        return try? Data(contentsOf: url)
    }

    func saveImageData(_ data: Data) {
        guard let url = profilePhotoURL() else { return }
        try? data.write(to: url, options: .atomic)
    }

    private func profilePhotoURL() -> URL? {
        fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(profilePhotoFileName)
    }
}

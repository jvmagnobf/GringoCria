//
//  ProgressService.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import Foundation
import Observation

// MARK: - ProgressService

@Observable
@MainActor
final class ProgressService {
    private(set) var completedIDs: Set<UUID> = []
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        load()
    }

    // MARK: - Public

    func markCompleted(id: UUID) {
        completedIDs.insert(id)
        save()
    }

    func isCompleted(id: UUID) -> Bool {
        completedIDs.contains(id)
    }

    // MARK: - Private

    private func load() {
        guard let raw = userDefaults.array(forKey: UserDefaultsKey.completedSubscenarioIDs) as? [String]
        else { return }
        completedIDs = Set(raw.compactMap { UUID(uuidString: $0) })
    }

    private func save() {
        let raw = completedIDs.map { $0.uuidString }
        userDefaults.set(raw, forKey: UserDefaultsKey.completedSubscenarioIDs)
    }
}

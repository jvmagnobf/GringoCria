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
    private(set) var completedIDs: Set<UUID>         = []
    private(set) var completedPhraseIDs: Set<String> = []

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        load()
    }

    // MARK: - Subscenario Progress

    func markCompleted(id: UUID) {
        completedIDs.insert(id)
        saveSubscenarios()
    }

    func isCompleted(id: UUID) -> Bool {
        completedIDs.contains(id)
    }

    // MARK: - Pronunciation Phrase Progress

    func markPhraseCompleted(id: String) {
        completedPhraseIDs.insert(id)
        savePhrases()
    }

    func isPhraseCompleted(id: String) -> Bool {
        completedPhraseIDs.contains(id)
    }

    /// Conta frases concluídas para um determinado nível, filtrando pelo prefixo do ID.
    /// Ex: nível "easy" filtra IDs que começam com "easy-".
    func completedPhraseCount(for level: PronunciationLevel) -> Int {
        let prefix = level.rawValue + "-"
        return completedPhraseIDs.filter { $0.hasPrefix(prefix) }.count
    }

    // MARK: - Private

    private func load() {
        if let raw = userDefaults.array(forKey: UserDefaultsKey.completedSubscenarioIDs) as? [String] {
            completedIDs = Set(raw.compactMap { UUID(uuidString: $0) })
        }
        if let raw = userDefaults.array(forKey: UserDefaultsKey.completedPhraseIDs) as? [String] {
            completedPhraseIDs = Set(raw)
        }
    }

    private func saveSubscenarios() {
        let raw = completedIDs.map { $0.uuidString }
        userDefaults.set(raw, forKey: UserDefaultsKey.completedSubscenarioIDs)
    }

    private func savePhrases() {
        let raw = Array(completedPhraseIDs)
        userDefaults.set(raw, forKey: UserDefaultsKey.completedPhraseIDs)
    }
}

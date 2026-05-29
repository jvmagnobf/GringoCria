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
    /// Melhor pontuação histórica por frase (1, 2 ou 3 estrelas). Ausente = nunca completou.
    private(set) var phraseStars: [String: Int]      = [:]

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

    /// Marca a frase como completa e atualiza a melhor pontuação se a nova for maior.
    func markPhraseCompleted(id: String, stars: Int) {
        completedPhraseIDs.insert(id)

        let clampedStars = max(1, min(3, stars))
        if clampedStars > (phraseStars[id] ?? 0) {
            phraseStars[id] = clampedStars
        }

        savePhrases()
    }

    func isPhraseCompleted(id: String) -> Bool {
        completedPhraseIDs.contains(id)
    }

    /// Retorna a melhor pontuação histórica (1-3) ou 0 se nunca completou.
    func bestStars(for id: String) -> Int {
        phraseStars[id] ?? 0
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
        if let raw = userDefaults.dictionary(forKey: UserDefaultsKey.phraseStars) as? [String: Int] {
            phraseStars = raw
        }
    }

    private func saveSubscenarios() {
        let raw = completedIDs.map { $0.uuidString }
        userDefaults.set(raw, forKey: UserDefaultsKey.completedSubscenarioIDs)
    }

    private func savePhrases() {
        let raw = Array(completedPhraseIDs)
        userDefaults.set(raw, forKey: UserDefaultsKey.completedPhraseIDs)
        userDefaults.set(phraseStars, forKey: UserDefaultsKey.phraseStars)
    }
}

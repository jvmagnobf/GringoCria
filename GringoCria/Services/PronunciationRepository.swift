//
//  PronunciationRepository.swift
//  GringoCria
//
//  Created by GringoCria on 25/05/26.
//
//  Carrega pronunciation-phrases.json do bundle de forma assíncrona.
//  Namespace sem estado — use `PronunciationRepository.load()` onde precisar.
//  Mesmo padrão do ScenarioRepository: Task.detached para evitar bloquear o MainActor.

import Foundation

// MARK: - PronunciationRepository

enum PronunciationRepository {
    // MARK: - Public

    /// Carrega e retorna as frases agrupadas por nível.
    static func load() async throws -> [PronunciationLevel: [PronunciationPhrase]] {
        guard let url = Bundle.main.url(forResource: "pronunciation-phrases", withExtension: "json") else {
            throw RepositoryError.fileNotFound
        }

        let data = try await Task.detached(priority: .utility) {
            try Data(contentsOf: url)
        }.value

        let container = try JSONDecoder().decode(PhrasesContainer.self, from: data)

        return [
            .easy:   container.easy,
            .medium: container.medium,
            .hard:   container.hard
        ]
    }

    // MARK: - Error

    enum RepositoryError: Error {
        case fileNotFound
    }
}

// MARK: - PhrasesContainer

/// Espelha a estrutura raiz do pronunciation-phrases.json:
/// `{ "version": 1, "easy": [...], "medium": [...], "hard": [...] }`
private struct PhrasesContainer: Decodable {
    let easy:   [PronunciationPhrase]
    let medium: [PronunciationPhrase]
    let hard:   [PronunciationPhrase]
}

//
//  CardsViewModel.swift
//  GringoCria
//
//  Created by GringoCria on 25/05/26.
//

import Foundation

// MARK: - CardsViewModel

@Observable
@MainActor
final class CardsViewModel {
    private(set) var phrasesByLevel: [PronunciationLevel: [PronunciationPhrase]] = [:]
    private(set) var isLoading: Bool  = false
    private(set) var loadError: String? = nil

    private let progressService: ProgressService

    init(progressService: ProgressService) {
        self.progressService = progressService
    }

    // MARK: - Public

    func load() async {
        guard phrasesByLevel.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            phrasesByLevel = try await PronunciationRepository.load()
        } catch {
            loadError = error.localizedDescription
            print("[CardsViewModel] Erro ao carregar frases: \(error)")
        }
    }

    func phrases(for level: PronunciationLevel) -> [PronunciationPhrase] {
        phrasesByLevel[level] ?? []
    }

    func completedCount(for level: PronunciationLevel) -> Int {
        progressService.completedPhraseCount(for: level)
    }

    func totalCount(for level: PronunciationLevel) -> Int {
        phrases(for: level).count
    }

    /// Retorna o progresso de 0.0 a 1.0 para o nível dado.
    func progressPercent(for level: PronunciationLevel) -> Double {
        let total = totalCount(for: level)
        guard total > 0 else { return 0 }
        return Double(completedCount(for: level)) / Double(total)
    }
}

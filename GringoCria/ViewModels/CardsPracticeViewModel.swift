//
//  CardsPracticeViewModel.swift
//  GringoCria
//
//  Created by GringoCria on 25/05/26.
//

import Foundation

// MARK: - PracticeFeedback

enum PracticeFeedback: Equatable {
    case idle
    case correct
    case incorrect(transcript: String)
}

// MARK: - CardsPracticeViewModel

@Observable
@MainActor
final class CardsPracticeViewModel {
    // MARK: - Public State

    private(set) var currentIndex: Int          = 0
    private(set) var feedback: PracticeFeedback = .idle
    private(set) var showTranslation: Bool      = false

    // MARK: - Private

    private let level:           PronunciationLevel
    private let phrases:         [PronunciationPhrase]
    private let progressService: ProgressService
    private let speechService:   SpeechRecognitionService

    init(
        level: PronunciationLevel,
        phrases: [PronunciationPhrase],
        progressService: ProgressService,
        speechService: SpeechRecognitionService
    ) {
        self.level           = level
        self.phrases         = phrases
        self.progressService = progressService
        self.speechService   = speechService

        // Começa no primeiro não concluído
        self.currentIndex = firstUncompletedIndex()
    }

    // MARK: - Computed

    var currentPhrase: PronunciationPhrase? {
        guard phrases.indices.contains(currentIndex) else { return nil }
        return phrases[currentIndex]
    }

    var total: Int { phrases.count }

    var completedCount: Int {
        progressService.completedPhraseCount(for: level)
    }

    var progressPercent: Double {
        guard total > 0 else { return 0 }
        return Double(completedCount) / Double(total)
    }

    var isRecording: Bool {
        speechService.isRecording
    }

    // MARK: - Public Actions

    func toggleTranslation() {
        showTranslation.toggle()
    }

    func startListening() {
        Task {
            guard await speechService.requestPermissions() else { return }
            try? await speechService.startRecording()
        }
    }

    func stopListening() {
        Task {
            guard let transcript = await speechService.stopRecording(),
                  let phrase     = currentPhrase
            else {
                feedback = .idle
                return
            }

            if isMatch(transcript: transcript, target: phrase.phrasePT) {
                feedback = .correct
                progressService.markPhraseCompleted(id: phrase.id)

                // Avança automaticamente após 800ms para o próximo não concluído
                try? await Task.sleep(for: .milliseconds(800))
                advance()
            } else {
                feedback = .incorrect(transcript: transcript)
            }
        }
    }

    func resetFeedback() {
        feedback = .idle
        showTranslation = false
    }

    // MARK: - Private

    /// Match exato após normalização: lowercase + sem pontuação + trim.
    /// Preserva acentos/nasais (sem diacritic folding) conforme decisão do plano.
    private func normalize(_ s: String) -> String {
        s.lowercased()
         .components(separatedBy: .punctuationCharacters).joined()
         .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func isMatch(transcript: String, target: String) -> Bool {
        normalize(transcript) == normalize(target)
    }

    private func advance() {
        feedback        = .idle
        showTranslation = false

        // Busca o próximo índice não concluído após o atual
        let nextIndex = ((currentIndex + 1)..<phrases.count).first {
            !progressService.isPhraseCompleted(id: phrases[$0].id)
        }
        // Se não encontrou após o atual, tenta desde o início
        ?? (0..<currentIndex).first {
            !progressService.isPhraseCompleted(id: phrases[$0].id)
        }

        if let next = nextIndex {
            currentIndex = next
        }
        // Se nil: todas concluídas — permanece no índice atual
    }

    private func firstUncompletedIndex() -> Int {
        phrases.indices.first {
            !progressService.isPhraseCompleted(id: phrases[$0].id)
        } ?? 0
    }
}

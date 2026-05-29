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
    /// O usuário acertou com 1, 2 ou 3 estrelas. Avança automaticamente.
    case success(stars: Int, transcript: String)
    /// O usuário errou (similaridade < 70%). Não avança.
    case failure(transcript: String)
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

    /// Melhor pontuação histórica (1-3) para a frase atual. 0 se nunca completou.
    var currentPhraseBestStars: Int {
        guard let phrase = currentPhrase else { return 0 }
        return progressService.bestStars(for: phrase.id)
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

            let stars = scoreMatch(transcript: transcript, target: phrase.phrasePT)

            if stars >= 1 {
                feedback = .success(stars: stars, transcript: transcript)
                progressService.markPhraseCompleted(id: phrase.id, stars: stars)

                // 3 estrelas avança rápido; 1-2 dá tempo de ler o feedback
                let delay: Duration = stars == 3 ? .milliseconds(900) : .milliseconds(1700)
                try? await Task.sleep(for: delay)
                advance()
            } else {
                feedback = .failure(transcript: transcript)
            }
        }
    }

    func resetFeedback() {
        feedback = .idle
        showTranslation = false
    }

    // MARK: - Private — Scoring

    /// Normaliza: lowercase + sem pontuação + trim. Preserva acentos/nasais.
    private func normalize(_ s: String) -> String {
        s.lowercased()
         .components(separatedBy: .punctuationCharacters).joined()
         .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Retorna 0 (falhou), 1, 2 ou 3 estrelas baseado na similaridade.
    /// 3★ = match exato, 2★ ≥ 85% similaridade, 1★ ≥ 70%.
    private func scoreMatch(transcript: String, target: String) -> Int {
        let normalizedTranscript = normalize(transcript)
        let normalizedTarget     = normalize(target)

        guard !normalizedTranscript.isEmpty, !normalizedTarget.isEmpty else { return 0 }

        if normalizedTranscript == normalizedTarget { return 3 }

        let similarity = similarityRatio(normalizedTranscript, normalizedTarget)

        switch similarity {
        case 0.85...: return 2
        case 0.70...: return 1
        default:      return 0
        }
    }

    /// Similaridade entre 0.0 e 1.0 usando distância de Levenshtein normalizada.
    private func similarityRatio(_ a: String, _ b: String) -> Double {
        let maxLen = max(a.count, b.count)
        guard maxLen > 0 else { return 1.0 }
        let distance = levenshteinDistance(a, b)
        return 1.0 - (Double(distance) / Double(maxLen))
    }

    /// Distância de Levenshtein — edições mínimas (insert/delete/substitute) para a → b.
    private func levenshteinDistance(_ a: String, _ b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)
        let m = aChars.count
        let n = bChars.count

        if m == 0 { return n }
        if n == 0 { return m }

        var previous = Array(0...n)
        var current  = Array(repeating: 0, count: n + 1)

        for i in 1...m {
            current[0] = i
            for j in 1...n {
                let cost = aChars[i - 1] == bChars[j - 1] ? 0 : 1
                current[j] = min(
                    previous[j] + 1,        // deletion
                    current[j - 1] + 1,     // insertion
                    previous[j - 1] + cost  // substitution
                )
            }
            swap(&previous, &current)
        }

        return previous[n]
    }

    // MARK: - Private — Navigation

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

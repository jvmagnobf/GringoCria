//
//  SpeechService.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import AVFoundation

// TODO: avaliar controle de velocidade via AVSpeechUtterance.rate

// MARK: - SpeechService
//
// @MainActor garante que todas as propriedades @Observable sejam acessadas
// apenas na main thread, eliminando o data race que o Swift 6 detecta na
// conformidade com AVSpeechSynthesizerDelegate (cujos callbacks chegam de
// threads arbitrárias do AVFoundation).
// Os métodos do delegate são marcados como nonisolated e despacham de volta
// para o MainActor via Task { @MainActor in … }.

@Observable
@MainActor
final class SpeechService: NSObject {
    private let synthesizer = AVSpeechSynthesizer()
    var isSpeaking: Bool             = false
    var currentSpeakingStepId: UUID? = nil

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Public

    func speak(text: String, stepId: UUID) {
        // Para fala anterior se houver
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = bestPortugueseBRVoice()
        // Ligeiramente mais devagar que o default (0.5) para facilitar o aprendizado
        utterance.rate = 0.47

        currentSpeakingStepId = stepId
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    // MARK: - Private

    /// Retorna a melhor voz pt-BR disponível no dispositivo:
    /// Premium > Enhanced > Default. Vozes de qualidade superior
    /// podem ser baixadas em Ajustes > Acessibilidade > Conteúdo Falado > Vozes.
    private func bestPortugueseBRVoice() -> AVSpeechSynthesisVoice? {
        let best = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language == "pt-BR" }
            .sorted { $0.quality.rawValue > $1.quality.rawValue }
            .first
        return best ?? AVSpeechSynthesisVoice(language: "pt-BR")
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        currentSpeakingStepId = nil
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechService: AVSpeechSynthesizerDelegate {
    // nonisolated: o protocolo não exige isolamento de ator.
    // Despachamos de volta ao MainActor para atualizar as propriedades @Observable
    // sem data race — compatível com Swift 6 strict concurrency.
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.isSpeaking = true
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.isSpeaking = false
            self?.currentSpeakingStepId = nil
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in
            self?.isSpeaking = false
            self?.currentSpeakingStepId = nil
        }
    }
}

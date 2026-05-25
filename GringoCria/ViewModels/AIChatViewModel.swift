//
//  AIChatViewModel.swift
//  GringoCria
//
//  Created by João Victor Magno on 15/05/26.
//

import Foundation
import Observation
import UIKit

// MARK: - AIChatViewModel

@Observable
@MainActor
final class AIChatViewModel {
    private(set) var messages: [ChatMessage] = []
    private(set) var isTyping: Bool = false
    private(set) var pendingFeedback: MessageFeedback?
    private(set) var errorMessage: String?
    private(set) var userProfileImage: UIImage?

    private let aiPersonaService: AIPersonaService
    private let aiAvailabilityService: AIAvailabilityService
    private let profileService: ProfileService

    init(
        aiPersonaService: AIPersonaService,
        aiAvailabilityService: AIAvailabilityService,
        /// ProfileService é stateless (struct) — não há estado compartilhado que exija
        /// injeção via @Environment, portanto o default local é aceitável aqui.
        /// Default `nil` evita avaliação em contexto nonisolated (Swift 6.2).
        profileService: ProfileService? = nil
    ) {
        self.aiPersonaService = aiPersonaService
        self.aiAvailabilityService = aiAvailabilityService
        self.profileService = profileService ?? ProfileService()
    }

    // MARK: - Public

    // loadUserPhoto() existe também em ScenarioViewModel — a duplicação é intencional:
    // profileService é privado em ambos os ViewModels e expô-lo só para eliminar
    // uma linha de delegação geraria acoplamento desnecessário.
    func loadUserPhoto() async {
        userProfileImage = await profileService.loadProfilePhoto()
    }

    /// Inicializa a conversa: cria as sessões e exibe a linha de abertura do personagem.
    func start(persona: Persona) async {
        aiPersonaService.setup(persona: persona)

        var opening = ChatMessage(role: .vendor, text: persona.openingLine)
        messages.append(opening)
        let openingIndex = messages.count - 1

        if let translation = try? await aiPersonaService.translateText(persona.openingLine) {
            opening.translationEN = translation
            messages[openingIndex] = opening
        }
    }

    /// Envia mensagem do usuário, obtém resposta do personagem e avaliação em paralelo.
    func send(_ text: String, persona: Persona) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        errorMessage = nil
        var userMessage = ChatMessage(role: .user, text: trimmed)
        messages.append(userMessage)
        let userIndex = messages.count - 1

        isTyping = true

        do {
            async let replyTask = aiPersonaService.sendMessage(trimmed, persona: persona)
            async let feedbackTask = aiPersonaService.evaluateMessage(
                trimmed,
                vendorReply: "",
                persona: persona
            )

            let reply = try await replyTask
            async let translationTask = aiPersonaService.translateText(reply)

            let feedback = try await feedbackTask
            let translation = try? await translationTask

            isTyping = false

            userMessage.feedback = feedback
            messages[userIndex] = userMessage
            pendingFeedback = feedback

            let vendorMessage = ChatMessage(role: .vendor, text: reply, translationEN: translation)
            messages.append(vendorMessage)

        } catch {
            isTyping = false
            errorMessage = error.localizedDescription
            print("[AIChatViewModel] Erro ao processar mensagem: \(error)")
        }
    }

    /// Encerra a conversa, limpa mensagens e libera as sessões de IA.
    func reset() {
        messages = []
        pendingFeedback = nil
        errorMessage = nil
        aiPersonaService.reset()
    }
}

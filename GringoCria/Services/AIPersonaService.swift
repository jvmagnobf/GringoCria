//
//  AIPersonaService.swift
//  GringoCria
//
//  Created by João Victor Magno on 15/05/26.
//

import Foundation
import Observation
import FoundationModels

// MARK: - AIPersonaService

@Observable
@MainActor
final class AIPersonaService {
    private var personaSession: LanguageModelSession?
    private var evaluatorSession: LanguageModelSession?
    private var translatorSession: LanguageModelSession?

    // MARK: - Public

    /// Cria as três sessões: personagem, avaliador e tradutor.
    func setup(persona: Persona) {
        personaSession = makePersonaSession(persona: persona)
        evaluatorSession = makeEvaluatorSession()
        translatorSession = makeTranslatorSession()
    }

    /// Envia mensagem do usuário para o personagem e retorna a resposta em PT.
    func sendMessage(_ text: String, persona: Persona) async throws -> String {
        guard let session = personaSession else {
            throw AIPersonaError.sessionNotInitialized
        }

        do {
            let response = try await session.respond(to: text)
            return response.content
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            // Janela de contexto excedida — recria a sessão e tenta novamente
            let newSession = makePersonaSession(persona: persona)
            personaSession = newSession
            let response = try await newSession.respond(to: text)
            return response.content
        }
    }

    /// Avalia a mensagem do usuário e retorna feedback estruturado.
    func evaluateMessage(
        _ userText: String,
        vendorReply: String,
        persona: Persona
    ) async throws -> MessageFeedback {
        guard let session = evaluatorSession else {
            throw AIPersonaError.sessionNotInitialized
        }

        let prompt = """
        The language learner sent this message in Portuguese: "\(userText)"
        The Carioca vendor replied: "\(vendorReply)"
        Evaluate the learner's message and provide feedback.
        """

        do {
            let response = try await session.respond(to: prompt, generating: MessageFeedback.self)
            return response.content
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            // Recria a sessão do avaliador e tenta novamente
            let newSession = makeEvaluatorSession()
            evaluatorSession = newSession
            let response = try await newSession.respond(to: prompt, generating: MessageFeedback.self)
            return response.content
        }
    }

    /// Traduz texto do português para o inglês.
    func translateText(_ text: String) async throws -> String {
        guard let session = translatorSession else {
            throw AIPersonaError.sessionNotInitialized
        }
        let response = try await session.respond(to: text)
        return response.content
    }

    /// Encerra a conversa e libera as sessões.
    func reset() {
        personaSession = nil
        evaluatorSession = nil
        translatorSession = nil
    }

    // MARK: - Private

    private func makePersonaSession(persona: Persona) -> LanguageModelSession {
        LanguageModelSession(instructions: persona.systemPrompt)
    }

    private func makeEvaluatorSession() -> LanguageModelSession {
        let instructions = """
        You are a Portuguese language coach specializing in Carioca (Rio de Janeiro) Portuguese.
        Your job is to evaluate messages written by language learners practicing Brazilian Portuguese.
        Analyze grammar, naturalness, and Carioca authenticity.
        Always respond with structured feedback as requested.
        Be encouraging but honest. Focus on practical improvements.
        """
        return LanguageModelSession(instructions: instructions)
    }

    private func makeTranslatorSession() -> LanguageModelSession {
        let instructions = """
        You are a Portuguese to English translator. When given Brazilian Portuguese text, respond only with its natural English translation. Do not add explanations, notes, or any extra text — only the translation.
        """
        return LanguageModelSession(instructions: instructions)
    }
}

// MARK: - AIPersonaError

enum AIPersonaError: LocalizedError {
    case sessionNotInitialized

    var errorDescription: String? {
        switch self {
        case .sessionNotInitialized:
            return "AI session not initialized. Call setup(persona:) first."
        }
    }
}

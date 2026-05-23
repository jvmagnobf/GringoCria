//
//  PersonaRepository.swift
//  GringoCria
//
//  Created by João Victor Magno on 15/05/26.
//

import Foundation

// MARK: - PersonaRepository

/// Carrega personas.json do bundle de forma assíncrona.
/// Namespace sem estado — use `PersonaRepository.load()` onde precisar.
struct PersonaRepository {
    // MARK: - Public

    static func load() async -> [Persona] {
        guard let url = Bundle.main.url(forResource: "personas", withExtension: "json")
        else { return [] }

        do {
            let data = try await Task.detached(priority: .utility) {
                try Data(contentsOf: url)
            }.value
            return (try? JSONDecoder().decode([Persona].self, from: data)) ?? []
        } catch {
            print("[PersonaRepository] Erro ao carregar personas.json: \(error)")
            return []
        }
    }
}

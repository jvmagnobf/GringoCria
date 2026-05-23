//
//  ScenarioRepository.swift
//  GringoCria
//
//  Created by João Victor Magno on 23/05/26.
//

import Foundation

// MARK: - ScenarioRepository

/// Carrega scenarios.json do bundle de forma assíncrona.
/// Namespace sem estado — use `ScenarioRepository.load()` onde precisar.
struct ScenarioRepository {
    // MARK: - Public

    static func load() async -> [Scenario] {
        guard let url = Bundle.main.url(forResource: "scenarios", withExtension: "json")
        else { return [] }

        do {
            let data = try await Task.detached(priority: .utility) {
                try Data(contentsOf: url)
            }.value
            return (try? JSONDecoder().decode([Scenario].self, from: data)) ?? []
        } catch {
            print("[ScenarioRepository] Erro ao carregar scenarios.json: \(error)")
            return []
        }
    }
}

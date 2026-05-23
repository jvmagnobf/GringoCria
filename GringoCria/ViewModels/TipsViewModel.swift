//
//  TipsViewModel.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import Foundation
import Observation

// MARK: - TipsViewModel

@Observable
@MainActor
final class TipsViewModel {
    private(set) var tips: [Tip] = []
    private(set) var loadError: String?

    // MARK: - Public

    func load() async {
        guard let url = Bundle.main.url(forResource: "tips", withExtension: "json") else {
            loadError = "Could not find tips.json"
            return
        }

        do {
            let data = try await Task.detached(priority: .utility) {
                try Data(contentsOf: url)
            }.value
            tips = try JSONDecoder().decode([Tip].self, from: data)
        } catch {
            loadError = "Could not load tips."
            print("[TipsViewModel] Erro: \(error)")
        }
    }
}

//
//  HomeViewModel.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//
//  IMPORTANTE: Certifique-se de que scenarios.json está adicionado como
//  resource do target GringoCria em Xcode → Build Phases → Copy Bundle Resources.
//  Com PBXFileSystemSynchronizedRootGroup (Xcode 16+) isso ocorre automaticamente.

import Foundation

@Observable
@MainActor
final class HomeViewModel {
    private(set) var scenarios: [Scenario] = []
    private(set) var isLoading: Bool = false
    private(set) var loadError: String?

    func load() async {
        isLoading = true
        defer { isLoading = false }

        guard let url = Bundle.main.url(forResource: "scenarios", withExtension: "json") else {
            print("[HomeViewModel] scenarios.json não encontrado no bundle.")
            return
        }

        do {
            // Data(contentsOf:) é I/O síncrono e bloquearia a main thread.
            // Movemos para uma task de background com withCheckedThrowingContinuation
            // via a API async do URLSession, ou simplesmente via Task.detached.
            // Como o arquivo está no bundle (leitura local e rápida), usamos
            // withCheckedThrowingContinuation para mover o I/O para fora do MainActor.
            let data = try await Task.detached(priority: .utility) {
                try Data(contentsOf: url)
            }.value
            scenarios = try JSONDecoder().decode([Scenario].self, from: data)
        } catch {
            print("[HomeViewModel] Erro ao decodificar scenarios.json: \(error)")
            scenarios = []
            loadError = "Could not load scenarios. Please restart the app."
        }
    }
}

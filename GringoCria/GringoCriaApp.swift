//
//  GringoCriaApp.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI

// MARK: - App Entry Point

@main
struct GringoCriaApp: App {
    @State private var appState       = AppState()
    @State private var speechService   = SpeechService()
    @State private var progressService = ProgressService()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environment(appState)
                .environment(speechService)
                .environment(progressService)
        }
    }
}

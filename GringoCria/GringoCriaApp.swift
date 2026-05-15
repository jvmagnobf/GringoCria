//
//  GringoCriaApp.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI

// MARK: - App Entry Point

@main
@available(iOS 26, *)
struct GringoCriaApp: App {
    @State private var appState               = AppState()
    @State private var speechService           = SpeechService()
    @State private var progressService         = ProgressService()
    @State private var aiAvailabilityService   = AIAvailabilityService()
    @State private var aiPersonaService        = AIPersonaService()
    @State private var premiumService          = PremiumService()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environment(appState)
                .environment(speechService)
                .environment(progressService)
                .environment(aiAvailabilityService)
                .environment(aiPersonaService)
                .environment(premiumService)
        }
    }
}

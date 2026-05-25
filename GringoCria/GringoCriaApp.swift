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
    @State private var appState                 = AppState()
    @State private var speechService             = SpeechService()
    @State private var speechRecognitionService  = SpeechRecognitionService()
    @State private var progressService           = ProgressService()
    @State private var aiAvailabilityService     = AIAvailabilityService()
    @State private var aiPersonaService          = AIPersonaService()
    @State private var premiumService            = PremiumService()

    init() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        // UITabBarAppearance removido para preservar o Liquid Glass nativo do iOS 26.
        // Qualquer customização de tint deve ser feita via accentColor no asset catalog.

        UIWindow.appearance().backgroundColor = UIColor(red: 0.04, green: 0.08, blue: 0.22, alpha: 1)
        UIScrollView.appearance().delaysContentTouches = false
    }

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environment(appState)
                .environment(speechService)
                .environment(speechRecognitionService)
                .environment(progressService)
                .environment(aiAvailabilityService)
                .environment(aiPersonaService)
                .environment(premiumService)
                .preferredColorScheme(ColorScheme.dark)
        }
    }
}

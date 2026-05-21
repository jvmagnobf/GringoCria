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

    init() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.stackedLayoutAppearance.normal.iconColor = .white
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        tabAppearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        UIWindow.appearance().backgroundColor = UIColor(red: 0.04, green: 0.08, blue: 0.22, alpha: 1)
        UIScrollView.appearance().delaysContentTouches = false
    }

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .preferredColorScheme(.dark)
                .environment(appState)
                .environment(speechService)
                .environment(progressService)
                .environment(aiAvailabilityService)
                .environment(aiPersonaService)
                .environment(premiumService)
        }
    }
}

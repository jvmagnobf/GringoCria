//
//  AuthenticatedTabView.swift
//  GringoCria
//
//  Created by João Victor Magno on 12/05/26.
//

import SwiftUI

// MARK: - AuthenticatedTabView

@available(iOS 26, *)
struct AuthenticatedTabView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Scenarios", systemImage: "house.fill")
                }

            NavigationStack {
                PremiumView()
            }
            .tabItem {
                Label("Premium", systemImage: "wand.and.sparkles")
            }

            NavigationStack {
                TipsView()
            }
            .tabItem {
                Label("Rio Tips", systemImage: "lightbulb.fill")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
        }
        .fullScreenCover(isPresented: .init(
            get: { !hasCompletedOnboarding },
            set: { _ in }
        )) {
            OnboardingView {
                hasCompletedOnboarding = true
            }
        }
    }
}

#Preview {
    if #available(iOS 26, *) {
        AuthenticatedTabView()
            .environment(AppState())
            .environment(SpeechService())
            .environment(ProgressService())
            .environment(AIAvailabilityService())
            .environment(AIPersonaService())
            .environment(PremiumService())
    }
}

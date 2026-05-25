//
//  AuthenticatedTabView.swift
//  GringoCria
//
//  Created by João Victor Magno on 12/05/26.
//

import SwiftUI

// MARK: - AuthenticatedTabView

struct AuthenticatedTabView: View {
    @AppStorage(UserDefaultsKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    // MARK: - ViewModel Ownership
    // Esta view é a única dona do HomeViewModel. HomeView depende
    // dele via @Environment(HomeViewModel.self). Se mover o HomeViewModel para outro
    // lugar sem atualizar o .environment(homeViewModel) abaixo, haverá crash em runtime.
    @State private var homeViewModel = HomeViewModel()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Scenarios", systemImage: "house.fill")
                }

            NavigationStack {
                CardsView()
            }
            .tabItem {
                Label("Cards", systemImage: "rectangle.on.rectangle.angled")
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
        .environment(homeViewModel)
        .task { await homeViewModel.load() }
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
    AuthenticatedTabView()
        .environment(AppState())
        .environment(SpeechService())
        .environment(ProgressService())
        .environment(AIAvailabilityService())
        .environment(AIPersonaService())
        .environment(PremiumService())
}

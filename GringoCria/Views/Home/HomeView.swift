//
//  HomeView.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI

// MARK: - HomeView

struct HomeView: View {
    @Environment(HomeViewModel.self) private var viewModel
    @State private var navigationPath = NavigationPath()
    @State private var pendingSubscenario: Subscenario?
    @State private var showDisclaimer = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                mainContent

                if showDisclaimer, let disclaimer = pendingSubscenario?.disclaimer {
                    DisclaimerOverlay(text: disclaimer) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showDisclaimer = false
                        }
                        Task {
                            try? await Task.sleep(for: .milliseconds(350))
                            if let sub = pendingSubscenario {
                                navigationPath.append(sub)
                            }
                        }
                    }
                    .transition(.opacity)
                }
            }
            .navigationDestination(for: Subscenario.self) { subscenario in
                if subscenario.isAIPremium {
                    AIChatEntryView(subscenario: subscenario)
                } else {
                    ScenarioView(subscenario: subscenario)
                }
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.scenarios.isEmpty {
                if viewModel.loadError != nil {
                    Text("Could not load scenarios. Please restart the app.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("No scenarios available yet.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                ScenarioListView(
                    scenarios: viewModel.scenarios,
                    mode: .scenarios,
                    onPremiumTap: handleSubscenarioTap
                )
            }
        }
        .background {
            Image("menu_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .navigationTitle("GringoCria")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Actions

    private func handleSubscenarioTap(_ subscenario: Subscenario) {
        if subscenario.disclaimer != nil {
            pendingSubscenario = subscenario
            withAnimation(.easeInOut(duration: 0.4)) { showDisclaimer = true }
        } else {
            navigationPath.append(subscenario)
        }
    }
}

// MARK: - DisclaimerOverlay

private struct DisclaimerOverlay: View {
    let text: String
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.82)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text(text)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()

                continueButton
                    .padding(.horizontal, 32)
                    .padding(.bottom, 52)
            }
        }
        .onTapGesture {
            onContinue()
        }
    }

    private var continueButton: some View {
        Text("Tap here to continue")
            .font(.headline)
            .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.25, blue: 0.52),
                            Color(red: 0.05, green: 0.10, blue: 0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.35), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.75
                        )
                }
        }
    }
}

#Preview {
    HomeView()
        .environment(HomeViewModel())
        .environment(AppState())
        .environment(ProgressService())
        .environment(AIAvailabilityService())
        .environment(AIPersonaService())
        .environment(PremiumService())
}

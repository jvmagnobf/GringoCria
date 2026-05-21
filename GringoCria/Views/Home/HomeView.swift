//
//  HomeView.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI

// MARK: - HomeView

@available(iOS 26, *)
struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var navigationPath = NavigationPath()
    @State private var pendingSubscenario: Subscenario?
    @State private var showDisclaimer = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                mainContent

                if showDisclaimer {
                    DisclaimerOverlay {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showDisclaimer = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            if let sub = pendingSubscenario {
                                navigationPath.append(sub)
                            }
                        }
                    }
                    .transition(.opacity)
                }
            }
            .navigationDestination(for: Subscenario.self) { subscenario in
                ScenarioView(subscenario: subscenario)
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
                    onPremiumTap: { subscenario in
                        guard !subscenario.isLocked else { return }
                        pendingSubscenario = subscenario
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showDisclaimer = true
                        }
                    }
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
        .task {
            await viewModel.load()
        }
    }
}

// MARK: - DisclaimerOverlay

@available(iOS 26, *)
private struct DisclaimerOverlay: View {
    let onContinue: () -> Void

    private let disclaimer = "The prices shown in this scenario are estimates based on common values found in Rio de Janeiro. They may vary depending on the beach, region, season, and establishment. If any price seems very different from the norm, stay alert."

    var body: some View {
        ZStack {
            Color.black.opacity(0.82)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text(disclaimer)
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
    if #available(iOS 26, *) {
        HomeView()
            .environment(AppState())
            .environment(ProgressService())
            .environment(AIAvailabilityService())
            .environment(AIPersonaService())
            .environment(PremiumService())
    }
}

//
//  PremiumView.swift
//  GringoCria
//
//  Created by Codex on 15/05/26.
//

import SwiftUI

// MARK: - PremiumView

struct PremiumView: View {
    @Environment(HomeViewModel.self) private var viewModel

    var body: some View {
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
                    mode: .premium,
                    onPremiumTap: { _ in }
                )
            }
        }
        .background {
            Image("menu_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Subscenario.self) { subscenario in
            AIChatEntryView(subscenario: subscenario)
        }
    }
}

#Preview {
    NavigationStack {
        PremiumView()
    }
    .environment(HomeViewModel())
    .environment(AppState())
    .environment(ProgressService())
    .environment(AIAvailabilityService())
    .environment(AIPersonaService())
    .environment(PremiumService())
}

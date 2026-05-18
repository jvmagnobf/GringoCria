//
//  PremiumView.swift
//  GringoCria
//
//  Created by Codex on 15/05/26.
//

import SwiftUI

// MARK: - PremiumView

@available(iOS 26, *)
struct PremiumView: View {
    @State private var viewModel = HomeViewModel()
    @State private var selectedPremiumSubscenario: Subscenario?

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
                    mode: .premium
                ) { subscenario in
                    selectedPremiumSubscenario = subscenario
                }
            }
        }
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedPremiumSubscenario) { subscenario in
            AIChatEntryView(subscenario: subscenario)
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    if #available(iOS 26, *) {
        NavigationStack {
            PremiumView()
        }
        .environment(AppState())
        .environment(ProgressService())
        .environment(AIAvailabilityService())
        .environment(AIPersonaService())
        .environment(PremiumService())
    }
}

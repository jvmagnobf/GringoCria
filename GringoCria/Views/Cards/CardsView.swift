//
//  CardsView.swift
//  GringoCria
//
//  Created by GringoCria on 25/05/26.
//

import SwiftUI

// MARK: - CardsView

struct CardsView: View {
    @Environment(ProgressService.self) private var progressService
    @Environment(SpeechRecognitionService.self) private var speechService

    @State private var viewModel: CardsViewModel?
    @State private var navigationPath   = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                backgroundGradient

                if let viewModel {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        levelList(viewModel: viewModel)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Pronunciation Cards")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: PracticeDestination.self) { destination in
                CardsPracticeView(
                    level: destination.level,
                    phrases: destination.phrases,
                    progressService: progressService,
                    speechService: speechService
                )
            }
        }
        .task {
            if viewModel == nil {
                viewModel = CardsViewModel(progressService: progressService)
            }
            await viewModel?.load()
        }
    }

    // MARK: - Private

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.08, blue: 0.22),
                Color(red: 0.08, green: 0.14, blue: 0.35)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func levelList(viewModel: CardsViewModel) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(PronunciationLevel.allCases, id: \.self) { level in
                    LevelCard(
                        level: level,
                        completed: viewModel.completedCount(for: level),
                        total: viewModel.totalCount(for: level),
                        progress: viewModel.progressPercent(for: level)
                    ) {
                        // Premium gate temporariamente desativado — todos os níveis acessíveis.
                        // A flag `level.isPremium` permanece no modelo para reativação futura.
                        let phrases = viewModel.phrases(for: level)
                        navigationPath.append(PracticeDestination(level: level, phrases: phrases))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
    }
}

// MARK: - PracticeDestination (navigation value)

/// Wrapper Hashable para NavigationStack.
private struct PracticeDestination: Hashable {
    let level:   PronunciationLevel
    let phrases: [PronunciationPhrase]

    func hash(into hasher: inout Hasher) { hasher.combine(level) }
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.level == rhs.level }
}

// MARK: - LevelCard

private struct LevelCard: View {
    let level:     PronunciationLevel
    let completed: Int
    let total:     Int
    let progress:  Double
    let onTap:     () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: level.icon)
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: 6) {
                    Text(level.titleEN)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("\(completed) / \(total) phrases")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))

                    ProgressView(value: progress)
                        .tint(.green)
                }

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(20)
            .glassEffect(in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CardsView()
        .environment(ProgressService())
        .environment(SpeechRecognitionService())
}

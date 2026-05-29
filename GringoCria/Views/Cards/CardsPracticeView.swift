//
//  CardsPracticeView.swift
//  GringoCria
//
//  Created by GringoCria on 25/05/26.
//

import SwiftUI

// MARK: - CardsPracticeView

struct CardsPracticeView: View {
    let level:           PronunciationLevel
    let phrases:         [PronunciationPhrase]
    let progressService: ProgressService
    let speechService:   SpeechRecognitionService

    @Environment(SpeechService.self) private var ttsService

    @State private var viewModel: CardsPracticeViewModel?

    var body: some View {
        ZStack {
            backgroundGradient

            if let viewModel {
                VStack(spacing: 0) {
                    progressHeader(viewModel: viewModel)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 24)

                    phraseCard(viewModel: viewModel)
                        .padding(.horizontal, 20)

                    Spacer()

                    feedbackArea(viewModel: viewModel)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    micButton(viewModel: viewModel)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                        .safeAreaPadding(.bottom)
                }
            }
        }
        .navigationTitle(level.titleEN)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel == nil {
                viewModel = CardsPracticeViewModel(
                    level: level,
                    phrases: phrases,
                    progressService: progressService,
                    speechService: speechService
                )
            }
        }
    }

    // MARK: - Progress Header

    private func progressHeader(viewModel: CardsPracticeViewModel) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(viewModel.completedCount) / \(viewModel.total) (\(Int(viewModel.progressPercent * 100))%)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
            }

            ProgressView(value: viewModel.progressPercent)
                .tint(.green)
        }
    }

    // MARK: - Phrase Card

    @ViewBuilder
    private func phraseCard(viewModel: CardsPracticeViewModel) -> some View {
        if let phrase = viewModel.currentPhrase {
            VStack(spacing: 16) {
                // Best score histórico (canto superior direito)
                HStack {
                    Spacer()
                    if viewModel.currentPhraseBestStars > 0 {
                        starsRow(filled: viewModel.currentPhraseBestStars, size: 12, spacing: 2, dimmed: true)
                            .transition(.opacity)
                    }
                }

                Text(phrase.phrasePT)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)

                if viewModel.showTranslation {
                    Text(phrase.translationEN)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                HStack(spacing: 24) {
                    // Ouvir a frase em pt-BR
                    Button {
                        ttsService.speak(text: phrase.phrasePT, stepId: UUID())
                    } label: {
                        Image(systemName: ttsService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2")
                            .font(.title2)
                            .foregroundStyle(ttsService.isSpeaking ? .green : .white.opacity(0.7))
                    }
                    .accessibilityLabel("Hear the phrase")

                    // Alternar tradução
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleTranslation()
                        }
                    } label: {
                        Image(systemName: viewModel.showTranslation ? "globe.badge.chevron.backward" : "globe")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .accessibilityLabel(viewModel.showTranslation ? "Hide translation" : "Show translation")
                }
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .glassEffect(in: RoundedRectangle(cornerRadius: 20))
        }
    }

    // MARK: - Feedback Area

    @ViewBuilder
    private func feedbackArea(viewModel: CardsPracticeViewModel) -> some View {
        Group {
            switch viewModel.feedback {
            case .idle:
                Text("Hold the button and speak the phrase")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)

            case .success(let stars, let transcript):
                successView(stars: stars, transcript: transcript)
                    .transition(.scale.combined(with: .opacity))

            case .failure(let transcript):
                VStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.red)
                    Text("You said: \"\(transcript)\"")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                    Text("Try again")
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.85))
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(minHeight: 110)
        .animation(.easeInOut(duration: 0.25), value: viewModel.feedback)
    }

    /// UI de sucesso com estrelas + mensagem contextual.
    private func successView(stars: Int, transcript: String) -> some View {
        VStack(spacing: 8) {
            starsRow(filled: stars, size: 32, spacing: 6)
                .shadow(color: .yellow.opacity(0.5), radius: 8)

            Text(successTitle(for: stars))
                .font(.headline)
                .foregroundStyle(stars == 3 ? .green : .yellow)

            if stars < 3 {
                Text("You said: \"\(transcript)\"")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func successTitle(for stars: Int) -> String {
        switch stars {
        case 3:  return "Perfect!"
        case 2:  return "Almost perfect!"
        default: return "Close enough — moving on!"
        }
    }

    // MARK: - Stars

    /// Linha de até 3 estrelas. `filled` define quantas estão preenchidas.
    private func starsRow(filled: Int, size: CGFloat, spacing: CGFloat, dimmed: Bool = false) -> some View {
        HStack(spacing: spacing) {
            ForEach(0..<3) { index in
                Image(systemName: index < filled ? "star.fill" : "star")
                    .font(.system(size: size, weight: .semibold))
                    .foregroundStyle(
                        index < filled
                            ? (dimmed ? Color.yellow.opacity(0.65) : Color.yellow)
                            : .white.opacity(0.25)
                    )
            }
        }
    }

    // MARK: - Mic Button (push-to-talk)

    private func micButton(viewModel: CardsPracticeViewModel) -> some View {
        let isRecording = viewModel.isRecording

        return Circle()
            .fill(isRecording ? Color.red.opacity(0.85) : Color.white.opacity(0.15))
            .frame(width: 80, height: 80)
            .overlay {
                Image(systemName: isRecording ? "mic.fill" : "mic")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
            }
            .glassEffect(in: Circle())
            .scaleEffect(isRecording ? 1.15 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isRecording)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isRecording else { return }
                        viewModel.resetFeedback()
                        viewModel.startListening()
                    }
                    .onEnded { _ in
                        viewModel.stopListening()
                    }
            )
            .accessibilityLabel(isRecording ? "Recording — release to check" : "Hold to record")
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        Image("FundoChatRio")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        CardsPracticeView(
            level: .easy,
            phrases: [
                PronunciationPhrase(
                    id: "easy-001",
                    phrasePT: "Bom dia",
                    translationEN: "Good morning",
                    difficultyHint: "Nasal 'om'"
                ),
                PronunciationPhrase(
                    id: "easy-002",
                    phrasePT: "Boa noite",
                    translationEN: "Good night",
                    difficultyHint: "Diphthong 'oi'"
                )
            ],
            progressService: ProgressService(),
            speechService: SpeechRecognitionService()
        )
    }
    .environment(SpeechService())
}

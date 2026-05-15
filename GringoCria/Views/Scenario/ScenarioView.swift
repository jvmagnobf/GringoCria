//
//  ScenarioView.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI

// TODO: validar com usuários se tradução deve aparecer por padrão

struct ScenarioView: View {
    let subscenario: Subscenario

    @State private var viewModel = ScenarioViewModel()
    @State private var showTranslation: Bool = false
    @Environment(SpeechService.self) private var speechService
    @Environment(ProgressService.self) private var progressService
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            conversationContent

            if viewModel.isCompleted {
                completionOverlay
            }
        }
        .navigationTitle(subscenario.titleEN)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showTranslation.toggle()
                } label: {
                    Image(systemName: showTranslation ? "globe.badge.chevron.backward" : "globe")
                }
                .accessibilityLabel("Toggle translation")
            }
        }
        .onAppear {
            viewModel.onCompleted = {
                progressService.markCompleted(id: subscenario.id)
            }
        }
        .task {
            await viewModel.start(scriptName: subscenario.scriptName)
        }
        .onDisappear {
            speechService.stop()
        }
    }

    // MARK: - Conversation Content

    private var conversationContent: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.revealedSteps) { step in
                            MessageBubble(
                                step: step,
                                showTranslation: showTranslation
                            )
                            .id(step.id)
                        }

                        if viewModel.isTyping {
                            TypingIndicator()
                                .id("typing")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: viewModel.revealedSteps.count) {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.isTyping) {
                    scrollToBottom(proxy: proxy)
                }
            }

            if !viewModel.isCompleted {
                choiceButtons
            }
        }
    }

    // MARK: - Choice Buttons

    @ViewBuilder
    private var choiceButtons: some View {
        if let choices = viewModel.currentChoices {
            VStack(spacing: 8) {
                ForEach(choices) { choice in
                    Button(choice.textPT) {
                        viewModel.selectChoice(choice)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
        }
    }

    // MARK: - Completion Overlay

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Well done!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("You completed this scenario.")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))

                Button("Back to Home") {
                    // dismiss() faz pop na NavigationStack sem alterar authState,
                    // preservando a pilha de navegação corretamente.
                    // Alterar authState aqui destruiria toda a NavigationStack
                    // e perderia o estado de outros subscenários em progresso.
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(32)
        }
    }

    // MARK: - Helpers

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.25)) {
            if viewModel.isTyping {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let last = viewModel.revealedSteps.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}

// MARK: - MessageBubble

private struct MessageBubble: View {
    let step: ScriptStep
    let showTranslation: Bool

    // Lê do ambiente para que as mudanças em currentSpeakingStepId disparem
    // atualizações de UI — passar como `let` não registra a dependência de
    // observação em @Observable corretamente para sub-views.
    @Environment(SpeechService.self) private var speechService

    private var isVendor: Bool { step.speaker == .vendor }
    private var isSpeakingThis: Bool { speechService.currentSpeakingStepId == step.id }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if isVendor {
                bubble
                speakerButton
                Spacer(minLength: 48)
            } else {
                Spacer(minLength: 48)
                speakerButton
                bubble
            }
        }
        .frame(maxWidth: .infinity, alignment: isVendor ? .leading : .trailing)
    }

    private var bubble: some View {
        VStack(alignment: isVendor ? .leading : .trailing, spacing: 4) {
            Text(step.textPT)
                .font(.body)
                .foregroundStyle(isVendor ? Color.primary : .white)

            if showTranslation && !step.translationEN.isEmpty {
                Text(step.translationEN)
                    .font(.caption)
                    .foregroundStyle(
                        isVendor
                            ? Color(.secondaryLabel)
                            : Color.white.opacity(0.75)
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isVendor ? Color(.systemGray5) : Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var speakerButton: some View {
        Button {
            if isSpeakingThis {
                speechService.stop()
            } else {
                speechService.speak(text: step.textPT, stepId: step.id)
            }
        } label: {
            Image(systemName: isSpeakingThis ? "speaker.slash" : "speaker.wave.2")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel(isSpeakingThis ? "Stop pronunciation" : "Play pronunciation")
    }
}

// MARK: - TypingIndicator

private struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color(.systemGray3))
                    .frame(width: 8, height: 8)
                    .offset(y: animating ? -4 : 0)
                    .animation(
                        .easeInOut(duration: 0.4)
                            .repeatForever()
                            .delay(Double(index) * 0.13),
                        value: animating
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { animating = true }
    }
}

#Preview {
    NavigationStack {
        ScenarioView(
            subscenario: Subscenario(
                id: UUID(),
                titlePT: "Matte",
                titleEN: "Mate drink",
                scriptName: "matte",
                isLocked: false
            )
        )
    }
    .environment(AppState())
    .environment(SpeechService())
    .environment(ProgressService())
}

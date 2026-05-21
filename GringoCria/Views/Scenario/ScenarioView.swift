//
//  ScenarioView.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI
import UIKit

// TODO: validar com usuários se tradução deve aparecer por padrão

struct ScenarioView: View {
    let subscenario: Subscenario

    @State private var viewModel = ScenarioViewModel()
    @State private var showTranslation: Bool = false
    @State private var introCompleted: Bool
    @State private var userProfileImage: UIImage?
    @Environment(SpeechService.self) private var speechService
    @Environment(ProgressService.self) private var progressService
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    private let profileService = ProfileService()

    init(subscenario: Subscenario) {
        self.subscenario = subscenario
        // Se houver intro em inglês, ela é a fonte preferida da UI. Caso contrário,
        // usamos o fallback em português.
        let hasIntro = !(Self.preferredIntroPages(for: subscenario)?.isEmpty ?? true)
        _introCompleted = State(initialValue: !hasIntro)
    }

    var body: some View {
        ZStack {
            Image("FundoChatRio")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            if introCompleted {
                if isIntroOnly {
                    introCompleteView
                } else {
                    conversationContent
                }
            }

            if !introCompleted,
               let pages = Self.preferredIntroPages(for: subscenario),
               !pages.isEmpty {
                IntroOverlayView(pages: pages) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        introCompleted = true
                    }
                }
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
        .task(id: introCompleted) {
            // Inicia conversa apenas após o intro ser dispensado e somente se houver script
            guard introCompleted, !subscenario.scriptName.isEmpty else { return }
            await viewModel.start(scriptName: subscenario.scriptName)
        }
        .task {
            userProfileImage = await profileService.loadProfilePhoto()
        }
        .onDisappear {
            speechService.stop()
        }
    }

    // MARK: - Intro Only

    private var isIntroOnly: Bool {
        subscenario.scriptName.isEmpty && !(Self.preferredIntroPages(for: subscenario)?.isEmpty ?? true)
    }

    private var introCompleteView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white)

            Text("Agora você já sabe o que esperar!")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Button("Back to Home") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                showTranslation: showTranslation,
                                subscenario: subscenario,
                                userProfileImage: userProfileImage
                            )
                            .id(step.id)
                        }

                        if viewModel.isTyping {
                            TypingIndicator(subscenario: subscenario)
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

            if viewModel.isCompleted {
                endChatButton
                    .safeAreaPadding(.bottom)
            } else {
                choiceButtons
                    .safeAreaPadding(.bottom)
            }
        }
    }

    // MARK: - Choice Buttons

    @ViewBuilder
    private var choiceButtons: some View {
        if let choices = viewModel.currentChoices {
            VStack(spacing: 8) {
                ForEach(choices) { choice in
                    let label = showTranslation && !choice.translationEN.isEmpty
                        ? choice.translationEN
                        : choice.textPT
                    Button {
                        viewModel.selectChoice(choice)
                    } label: {
                        Text(label)
                            .font(.body)
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(ChatStyling.userBubbleColor)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                    .buttonStyle(.plain)
                    .shadow(color: .black.opacity(0.10), radius: 4, y: 2)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }

    // MARK: - End Chat Button

    private var endChatButton: some View {
        VStack(spacing: 0) {
            Text("Conversa encerrada 🎉")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.top, 8)

            Button("Encerrar") {
                // dismiss() faz pop na NavigationStack sem alterar authState,
                // preservando a pilha de navegação corretamente.
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Helpers

    private static func preferredIntroPages(for subscenario: Subscenario) -> [String]? {
        if let introPagesEN = subscenario.introPagesEN, !introPagesEN.isEmpty {
            return introPagesEN
        }

        return subscenario.introPages
    }

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
    let subscenario: Subscenario
    let userProfileImage: UIImage?

    // Lê do ambiente para que as mudanças em currentSpeakingStepId disparem
    // atualizações de UI — passar como `let` não registra a dependência de
    // observação em @Observable corretamente para sub-views.
    @Environment(SpeechService.self) private var speechService

    private var isVendor: Bool { step.speaker == .vendor }
    private var isSpeakingThis: Bool { speechService.currentSpeakingStepId == step.id }
    private var vendorIconName: String? { ChatStyling.vendorIconName(for: subscenario) }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if isVendor {
                ChatVendorAvatarView(iconName: vendorIconName)
                bubbleRow
                Spacer(minLength: 24)
            } else {
                Spacer(minLength: 24)
                bubbleRow
                ChatUserAvatarView(image: userProfileImage)
            }
        }
        .frame(maxWidth: .infinity, alignment: isVendor ? .leading : .trailing)
    }

    private var bubbleRow: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if isVendor {
                bubble
                speakerButton
            } else {
                speakerButton
                bubble
            }
        }
    }

    private var bubble: some View {
        VStack(alignment: isVendor ? .leading : .trailing, spacing: 4) {
            Text(step.textPT)
                .font(.body)
                .foregroundStyle(Color("mensagem_fonte"))

            if showTranslation && !step.translationEN.isEmpty {
                Text(step.translationEN)
                    .font(.caption)
                    .foregroundStyle(Color("mensagem_fonte").opacity(0.65))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isVendor ? ChatStyling.vendorBubbleColor : ChatStyling.userBubbleColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.10), radius: 4, y: 2)
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
    let subscenario: Subscenario
    @State private var animating = false

    private var vendorIconName: String? {
        ChatStyling.vendorIconName(for: subscenario)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ChatVendorAvatarView(iconName: vendorIconName)

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
            .background(ChatStyling.vendorBubbleColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.10), radius: 4, y: 2)

            Spacer(minLength: 24)
        }
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
                isLocked: false,
                introPages: nil,
                introPagesEN: nil,
                vendorIcon: nil
            )
        )
    }
    .environment(AppState())
    .environment(SpeechService())
    .environment(ProgressService())
}

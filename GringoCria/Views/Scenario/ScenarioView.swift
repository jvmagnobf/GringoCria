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

    @State private var viewModel: ScenarioViewModel?
    @State private var showTranslation: Bool = false
    @State private var introCompleted: Bool
    @Environment(SpeechService.self) private var speechService
    @Environment(AppState.self) private var appState
    @Environment(ProgressService.self) private var progressService
    @Environment(\.dismiss) private var dismiss

    init(subscenario: Subscenario) {
        self.subscenario = subscenario
        // Se houver intro em inglês, ela é a fonte preferida da UI. Caso contrário,
        // usamos o fallback em português.
        let hasIntro = !(subscenario.preferredIntroPages?.isEmpty ?? true)
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
               let pages = subscenario.preferredIntroPages,
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
        .task {
            if viewModel == nil {
                viewModel = ScenarioViewModel(progressService: progressService)
            }
        }
        .task(id: introCompleted) {
            // Inicia conversa apenas após o intro ser dispensado e somente se houver script
            guard introCompleted, !subscenario.scriptName.isEmpty else { return }
            await viewModel?.start(scriptName: subscenario.scriptName, subscenarioId: subscenario.id)
        }
        .onChange(of: introCompleted) { _, completed in
            // Fix: cenários intro-only (ex: Ambulantes) não passam pelo fluxo de script,
            // então a conclusão precisa ser registrada manualmente quando o intro termina.
            if completed && isIntroOnly {
                viewModel?.markIntroOnlyCompleted(id: subscenario.id)
            }
        }
        .task {
            await viewModel?.loadUserPhoto()
        }
        .onDisappear {
            speechService.stop()
        }
    }

    // MARK: - Intro Only

    private var isIntroOnly: Bool {
        subscenario.scriptName.isEmpty && !(subscenario.preferredIntroPages?.isEmpty ?? true)
    }

    private var introCompleteView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white)

            Text("Now you know what to expect!")
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

    @ViewBuilder
    private var conversationContent: some View {
        // viewModel é inicializado no primeiro .task — não é nil quando conversationContent é exibido
        if let viewModel {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if let headerImage = ChatStyling.headerImageName(for: subscenario) {
                                ConversationHeaderImage(
                                    imageName: headerImage,
                                    label: subscenario.titleEN
                                )
                                .padding(.bottom, 4)
                            }

                            ForEach(viewModel.revealedSteps) { step in
                                MessageBubble(
                                    step: step,
                                    showTranslation: showTranslation,
                                    subscenario: subscenario,
                                    userProfileImage: viewModel.userProfileImage
                                )
                                .id(step.id)
                            }

                            if viewModel.isTyping {
                                TypingIndicatorView(vendorIconName: ChatStyling.vendorIconName(for: subscenario))
                                    .id("typing")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: viewModel.revealedSteps.count) {
                        scrollToBottom(proxy: proxy, viewModel: viewModel)
                    }
                    .onChange(of: viewModel.isTyping) {
                        scrollToBottom(proxy: proxy, viewModel: viewModel)
                    }
                }

                if viewModel.isCompleted {
                    endChatButton
                        .safeAreaPadding(.bottom)
                } else {
                    choiceButtons(viewModel: viewModel)
                        .safeAreaPadding(.bottom)
                }
            }
        }
    }

    // MARK: - Choice Buttons

    @ViewBuilder
    private func choiceButtons(viewModel: ScenarioViewModel) -> some View {
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
                            .foregroundStyle(Color("mensagem_fonte"))
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
            Text("Conversation ended")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.top, 8)

            Button("Finish") {
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

    private func scrollToBottom(proxy: ScrollViewProxy, viewModel: ScenarioViewModel) {
        proxy.scrollToLatest(isTyping: viewModel.isTyping, lastId: viewModel.revealedSteps.last?.id)
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
                vendorIcon: nil,
                disclaimer: nil,
                requiresCompletionOf: nil
            )
        )
    }
    .environment(AppState())
    .environment(SpeechService())
    .environment(ProgressService())
}

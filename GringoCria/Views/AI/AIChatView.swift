//
//  AIChatView.swift
//  GringoCria
//
//  Created by João Victor Magno on 15/05/26.
//

import SwiftUI

// MARK: - AIChatView

struct AIChatView: View {
    let persona: Persona

    @State private var viewModel: AIChatViewModel
    @Environment(SpeechRecognitionService.self) private var speechService

    @State private var inputText: String = ""
    @State private var showTranslation: Bool = false
    @FocusState private var isInputFocused: Bool

    init(persona: Persona, aiPersonaService: AIPersonaService, aiAvailabilityService: AIAvailabilityService) {
        self.persona = persona
        _viewModel = State(
            initialValue: AIChatViewModel(
                aiPersonaService: aiPersonaService,
                aiAvailabilityService: aiAvailabilityService
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            messageList
            inputBar
        }
        .background {
            Image("FundoChatRio")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .navigationTitle(persona.nameEN)
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
            await viewModel.start(persona: persona)
            await viewModel.loadUserPhoto()
        }
        .onDisappear {
            viewModel.reset()
            if speechService.isRecording {
                Task { await speechService.stopRecording() }
            }
        }
        .onChange(of: speechService.lastTranscript) { _, transcript in
            guard speechService.isRecording else { return }
            inputText = transcript
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(
                            message: message,
                            showTranslation: showTranslation,
                            persona: persona,
                            userProfileImage: viewModel.userProfileImage
                        )
                            .id(message.id)

                        if message.role == .user, let feedback = message.feedback {
                            FeedbackBubble(feedback: feedback, userText: message.text)
                                .id("\(message.id)-feedback")
                        }
                    }

                    if viewModel.isTyping {
                        TypingIndicatorView(vendorIconName: ChatStyling.vendorIconName(for: persona))
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture { isInputFocused = false }
            .onChange(of: viewModel.messages.count) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isTyping) {
                scrollToBottom(proxy: proxy)
            }
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 8) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 12) {
                TextField(
                    "",
                    text: $inputText,
                    prompt: Text(speechService.isRecording ? "Listening..." : "Type in Portuguese...")
                        .foregroundStyle(Color("mensagem_fonte")),
                    axis: .vertical
                )
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .submitLabel(.send)
                .onSubmit(sendMessage)
                .focused($isInputFocused)
                .foregroundStyle(Color("mensagem_fonte"))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(ChatStyling.inputBackgroundColor)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.10), radius: 4, y: 2)
                .disabled(speechService.isRecording)

                voiceOrSendButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Helpers

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !viewModel.isTyping
            && !speechService.isRecording
    }

    @ViewBuilder
    private var voiceOrSendButton: some View {
        if speechService.isRecording {
            // Stop recording
            Button {
                Task { await speechService.stopRecording() }
            } label: {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.red)
                    .frame(width: 46, height: 46)
                    .background(ChatStyling.sendButtonColor.opacity(0.85))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
            }
        } else if canSend {
            // Send typed message
            Button {
                sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.blue.opacity(0.95))
                    .frame(width: 46, height: 46)
                    .background(ChatStyling.sendButtonColor)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
            }
        } else {
            // Start voice recording
            Button {
                Task { await toggleRecording() }
            } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(.systemGray2))
                    .frame(width: 46, height: 46)
                    .background(ChatStyling.sendButtonColor.opacity(0.75))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
            }
        }
    }

    private func toggleRecording() async {
        if speechService.isRecording {
            await speechService.stopRecording()
        } else {
            if !speechService.permissionGranted {
                let granted = await speechService.requestPermissions()
                guard granted else { return }
            }
            isInputFocused = false
            inputText = ""
            try? await speechService.startRecording()
        }
    }

    private func sendMessage() {
        let text = inputText
        inputText = ""
        Task {
            await viewModel.send(text, persona: persona)
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        proxy.scrollToLatest(isTyping: viewModel.isTyping, lastId: viewModel.messages.last?.id)
    }
}



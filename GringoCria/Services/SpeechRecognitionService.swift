//
//  SpeechRecognitionService.swift
//  GringoCria
//
//  Created by GringoCria on 25/05/26.
//
//  Encapsula SFSpeechRecognizer + AVAudioEngine para reconhecimento de fala em pt-BR.
//  @MainActor garante acesso seguro às propriedades @Observable.
//  Os callbacks do AVAudioEngine chegam em threads arbitrárias — instalamos o tap
//  com captura weak e despachamos ao MainActor via Task, mesmo padrão do SpeechService.swift.

import AVFoundation
import Speech

// MARK: - SpeechRecognitionService

@Observable
@MainActor
final class SpeechRecognitionService {
    private(set) var isRecording: Bool       = false
    private(set) var permissionGranted: Bool = false
    private(set) var errorMessage: String?   = nil

    /// Transcrição acumulada durante e após a gravação.
    private(set) var lastTranscript: String  = ""

    // MARK: - Private

    private let audioEngine      = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "pt-BR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    // MARK: - Public

    /// Solicita permissões de microfone e reconhecimento de fala.
    /// Deve ser chamado antes de `startRecording()`.
    func requestPermissions() async -> Bool {
        let micGranted     = await requestMicrophonePermission()
        let speechGranted  = await requestSpeechPermission()
        let allGranted     = micGranted && speechGranted
        permissionGranted  = allGranted
        return allGranted
    }

    /// Inicia gravação e reconhecimento em tempo real (pt-BR).
    /// Lança erro se o AVAudioEngine não conseguir iniciar.
    func startRecording() async throws {
        guard permissionGranted else {
            errorMessage = "Permissions not granted. Call requestPermissions() first."
            return
        }
        guard !isRecording else { return }

        lastTranscript = ""
        errorMessage   = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let inputNode     = audioEngine.inputNode
        let recordFormat  = inputNode.outputFormat(forBus: 0)

        // nonisolated context: o tap chega numa thread do AVAudioEngine.
        // Capturamos weak self e despachamos ao MainActor.
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let result {
                    self.lastTranscript = result.bestTranscription.formattedString
                }
                if let error, !self.isRecording {
                    // Só propaga erro se não for o cancelamento intencional
                    self.errorMessage = error.localizedDescription
                }
            }
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true
    }

    /// Para a gravação e retorna a transcrição final.
    /// Retorna nil se nada foi capturado.
    @discardableResult
    func stopRecording() async -> String? {
        guard isRecording else { return nil }

        isRecording = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        return lastTranscript.isEmpty ? nil : lastTranscript
    }

    // MARK: - Private Helpers

    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    private func requestSpeechPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

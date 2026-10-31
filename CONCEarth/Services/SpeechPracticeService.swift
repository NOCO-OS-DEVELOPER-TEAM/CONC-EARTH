import AVFoundation
import Combine
import Foundation
import Speech

@MainActor
final class SpeechPracticeService: ObservableObject {
    @Published var isListening = false
    @Published var transcript = ""
    @Published var authorizationDenied = false

    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))

    func requestAccess(completion: (() -> Void)? = nil) {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                self?.authorizationDenied = status != .authorized
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    Task { @MainActor in
                        if !granted { self?.authorizationDenied = true }
                        completion?()
                    }
                }
            }
        }
    }

    func start() {
        guard !isListening else { return }
        requestAccess { [weak self] in
            self?.beginListening()
        }
    }

    private func beginListening() {
        guard recognizer?.isAvailable == true, !authorizationDenied else { return }
        transcript = ""

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.request = request

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            authorizationDenied = true
            return
        }

        task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                if let result {
                    self?.transcript = result.bestTranscription.formattedString
                }
                if error != nil || result?.isFinal == true {
                    self?.stop()
                }
            }
        }
        isListening = true
    }

    func stop() {
        guard isListening || audioEngine.isRunning else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        isListening = false
    }
}

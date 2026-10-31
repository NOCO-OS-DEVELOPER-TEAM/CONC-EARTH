import AudioToolbox
import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioService: ObservableObject {
    @Published var isCabinNoisePlaying = false

    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var noiseBuffer: AVAudioPCMBuffer?

    func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    func playBoardingChime(enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(1057)
    }

    func playTakeoff(enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(1110)
        // Soft rising whoosh via short cabin burst
        setCabinNoise(enabled: true, soundsOn: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            // leave cabin noise to caller preference; don't force stop
            _ = self
        }
    }

    func playLanding(enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(1025)
    }

    func setCabinNoise(enabled: Bool, soundsOn: Bool) {
        guard soundsOn, enabled else {
            stopCabinEngine()
            return
        }
        startCabinEngine()
    }

    func stopAll() {
        stopCabinEngine()
    }

    private func startCabinEngine() {
        if engine?.isRunning == true, playerNode?.isPlaying == true {
            isCabinNoisePlaying = true
            return
        }

        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)

        let format = AVAudioFormat(standardFormatWithSampleRate: 22050, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.22

        let buffer = makePinkishNoiseBuffer(format: format, seconds: 2.0)
        noiseBuffer = buffer

        do {
            try engine.start()
            player.scheduleBuffer(buffer, at: nil, options: [.loops], completionHandler: nil)
            player.volume = 0.35
            player.play()
            self.engine = engine
            self.playerNode = player
            isCabinNoisePlaying = true
        } catch {
            isCabinNoisePlaying = false
        }
    }

    private func stopCabinEngine() {
        playerNode?.stop()
        engine?.stop()
        playerNode = nil
        engine = nil
        isCabinNoisePlaying = false
    }

    private func makePinkishNoiseBuffer(format: AVAudioFormat, seconds: Double) -> AVAudioPCMBuffer {
        let frames = AVAudioFrameCount(format.sampleRate * seconds)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
        buffer.frameLength = frames
        guard let data = buffer.floatChannelData?[0] else { return buffer }

        var b0: Float = 0, b1: Float = 0, b2: Float = 0
        for i in 0..<Int(frames) {
            let white = Float.random(in: -1...1)
            // Simple pink-ish filter for soft cabin rumble
            b0 = 0.99765 * b0 + white * 0.0990460
            b1 = 0.96300 * b1 + white * 0.2965164
            b2 = 0.57000 * b2 + white * 1.0526913
            var sample = (b0 + b1 + b2 + white * 0.1848) * 0.05
            // Mild low rumble emphasis
            sample = max(-1, min(1, sample))
            data[i] = sample
        }
        return buffer
    }
}

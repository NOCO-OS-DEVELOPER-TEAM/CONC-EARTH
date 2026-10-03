import AudioToolbox
import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioService: ObservableObject {
    @Published var isCabinNoisePlaying = false

    private var cabinPlayer: AVAudioPlayer?

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
        AudioServicesPlaySystemSound(1113)
    }

    func playLanding(enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(1025)
    }

    func setCabinNoise(enabled: Bool, soundsOn: Bool) {
        guard soundsOn, enabled else {
            cabinPlayer?.stop()
            isCabinNoisePlaying = false
            return
        }
        if cabinPlayer == nil {
            cabinPlayer = makeSoftNoisePlayer()
        }
        cabinPlayer?.volume = 0.18
        cabinPlayer?.numberOfLoops = -1
        cabinPlayer?.play()
        isCabinNoisePlaying = cabinPlayer?.isPlaying == true
    }

    func stopAll() {
        cabinPlayer?.stop()
        isCabinNoisePlaying = false
    }

    private func makeSoftNoisePlayer() -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: "cabin_noise", withExtension: "m4a")
                ?? Bundle.main.url(forResource: "cabin_noise", withExtension: "mp3") else {
            return nil
        }
        return try? AVAudioPlayer(contentsOf: url)
    }
}

import Combine
import Foundation

@MainActor
final class FocusTimerService: ObservableObject {
    @Published private(set) var now: Date = Date()

    private var timer: AnyCancellable?

    func start() {
        stop()
        now = Date()
        timer = Timer.publish(every: 0.25, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.now = date
            }
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }
}

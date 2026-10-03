import ActivityKit
import Foundation

struct FocusFlightAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var originIATA: String
        var destinationIATA: String
        var remainingSeconds: Int
        var progress: Double
        var statusText: String
        var seatCode: String
    }

    var flightNumber: String
    var scenarioTitle: String
}

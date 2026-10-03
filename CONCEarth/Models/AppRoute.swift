import Foundation

enum AppScreen: Equatable {
    case home
    case takeMeSomewhere
    case flightSelection
    case focusPurpose
    case seatSelection
    case ticket
    case boarding
    case takeoff
    case inFlight
    case landing
    case arrival
    case flightLog
    case world
    case journey
    case boardingPass(UUID)
}

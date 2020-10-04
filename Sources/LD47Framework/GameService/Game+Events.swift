import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable identifier_name
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length

class EventPlayerKill: Codable {
    var tag = "EventPlayerKill"

    var player: Player
    var score: Int

    init(_ player: Player, _ score: Int) {
        self.player = player
        self.score = score
    }
}

class EventPlayerBonus: Codable {
    var tag = "EventPlayerBonus"

    var player: Player
    var score: Int

    init(_ player: Player, _ score: Int) {
        self.player = player
        self.score = score
    }
}

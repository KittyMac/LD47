import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

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

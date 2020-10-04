import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable identifier_name

class Player: Codable {
    var id: String
    var name: String
    var teamId: Int = 0
    var nodeIdx: Int = 0
    var inTransit: Bool = false
    var hint: String = ""

    // Neat trick: lazy properties are excluded from codable
    public lazy var lastMoveTime: TimeInterval = 0.0
    public lazy var distanceToExit: Int = 0

    init(_ id: String, _ teamId: Int, _ name: String) {
        self.id = id
        self.name = name
        self.teamId = teamId

        if name.count <= 0 {
            let randomNames = [
                "Sulley",
                "Jesse",
                "Leonidas",
                "Edward",
                "Theo",
                "Kirk",
                "Elizabeth",
                "Ben",
                "Gopnik",
                "Richard",
                "Kowalski",
                "Wilson",
                "Shaun",
                "Kym",
                "Penny",
                "Nick",
                "Vincent"
            ]

            if let randomName = randomNames.randomElement() {
                self.name = randomName
            }
        }
    }

    func playerDidMove(_ distanceToExit: Int) {
        self.distanceToExit = distanceToExit
        lastMoveTime = ProcessInfo.processInfo.systemUptime
        updateHint()
    }

    func updateHint() {
        let t = ProcessInfo.processInfo.systemUptime

        let timeLeft = Int((8.0 - (t - lastMoveTime)))

        if timeLeft > 5 {
            hint = ""
        } else if timeLeft > 0 {
            hint = "\(timeLeft)s"
        } else {
            hint = "\(distanceToExit) moves\nto the exit"
        }
    }
}

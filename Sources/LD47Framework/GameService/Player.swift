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
}

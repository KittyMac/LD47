import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable identifier_name

class Player: Codable {
    var id: String
    var name: String
    var nodeIdx: Int = 0

    init(_ id: String, _ name: String) {
        self.id = id
        self.name = name
    }
}

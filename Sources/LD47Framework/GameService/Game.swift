import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable identifier_name

// The network of nodes is a tight array of nodes, each node
// has a X/Y position and can contain up to four connections
// to other nodes. d is the distance needed to travel from
// here to the exit.  The exit is always node 0.

typealias NodeIndex = Int16
let kNoNode: NodeIndex = 32767

let kMaxDistance: Int16 = 32767

class Node: Codable {
    var id: NodeIndex = kNoNode
    var x: Int16
    var y: Int16
    var n0: NodeIndex = kNoNode
    var n1: NodeIndex = kNoNode
    var n2: NodeIndex = kNoNode
    var n3: NodeIndex = kNoNode
    var d: Int16

    init(_ id: Int16, _ x: Int16, _ y: Int16) {
        self.id = id
        self.x = x
        self.y = y
        self.d = kMaxDistance
    }

    func to(_ other: Int16) -> Self {
        if n0 == kNoNode { n0 = other; return self}
        if n1 == kNoNode { n1 = other; return self}
        if n2 == kNoNode { n2 = other; return self}
        if n3 == kNoNode { n3 = other; return self}
        return self
    }
}

struct BoardUpdate: Codable {
    var tag: String = "BoardUpdate"
    var nodes: [Node]
    var players: [Player]
}

struct PlayerInfo: Codable {
    var tag: String = "PlayerInfo"
    var player: Player
}

class Game {
    var nodes: [Node] = []
    var players: [String: Player] = [:]

    init() {

    }

    init(_ seed: Int32) {
        nodes.append(Node(0, 0, 0).to(1))
        nodes.append(Node(1, 5, 0).to(0).to(2).to(3))
        nodes.append(Node(2, 10, 5).to(1))
        nodes.append(Node(3, 10, -5).to(1))
    }

    func addPlayer(_ playerID: String, _ playerName: String) -> PlayerInfo {
        if let player = players[playerID] {
            return PlayerInfo(player: player)
        }
        let player = Player(playerID, playerName)
        players[playerID] = player
        return PlayerInfo(player: player)
    }

    func getBoardUpdate(_ playerID: String) -> BoardUpdate {
        // TODO: retrieve the portion of the board around the requested node position. This
        // prevents sending the entire game universe to the client every time it is requested
        return BoardUpdate(nodes: nodes, players: Array(players.values))
    }

}

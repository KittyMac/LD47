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

typealias NodeIndex = Int
let kNoNode: NodeIndex = 32767

let kMaxDistance: Int = 32767

class Node: Codable, Equatable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }

    var id: NodeIndex = kNoNode
    var x: Int
    var y: Int
    var c: [NodeIndex] = []
    var d: Int

    init(_ id: Int, _ x: Int, _ y: Int) {
        self.id = id
        self.x = x
        self.y = y
        self.d = kMaxDistance
    }

    func to(_ other: Int) -> Self {
        c.append(other)
        return self
    }
}

struct BoardUpdate: Codable {
    var tag: String = "BoardUpdate"
    var nodes: [Node]
    var players: [Player]
    var player: Player?
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
        nodes.append(Node(0, 0, 0).to(1).to(6))
        nodes.append(Node(1, 5, 0).to(0).to(2).to(3))
        nodes.append(Node(2, 10, 5).to(1))
        nodes.append(Node(3, 10, -5).to(1).to(4))
        nodes.append(Node(4, 30, -30).to(3).to(5))
        nodes.append(Node(5, 90, -90).to(4))

        nodes.append(Node(6, -9000, 9000).to(0))
    }

    func addPlayer(_ playerID: String, _ playerName: String) -> PlayerInfo {
        if let player = players[playerID] {
            return PlayerInfo(player: player)
        }
        let player = Player(playerID, playerName)
        players[playerID] = player
        return PlayerInfo(player: player)
    }

    func getBoardUpdate(_ playerID: String, _ visWidth: Int, _ visHeight: Int) -> BoardUpdate? {
        // 0. find the player's node
        if let player = players[playerID] {
            let playerNode = nodes[player.nodeIdx]

            // 1. only include nodes and players which are visible to this player
            var visNodes: [Node] = []
            var visPlayers: [Player] = []

            for node in nodes {
                if  abs(node.x - playerNode.x) < visWidth * 2 &&
                    abs(node.y - playerNode.y) < visHeight * 2 {
                    visNodes.append(node)
                }
            }

            // 2. run back through the nodes, add any nodes which are connected to a visNode
            for node in visNodes {
                for neighborIdx in node.c {
                    let neighbor = nodes[neighborIdx]
                    if visNodes.contains(neighbor) == false {
                        visNodes.append(neighbor)
                    }
                }
            }

            // add players who are visible
            for otherPlayer in players.values {
                let otherPlayerNode = nodes[otherPlayer.nodeIdx]
                if  abs(otherPlayerNode.x - playerNode.x) < visWidth &&
                    abs(otherPlayerNode.y - playerNode.y) < visHeight {
                    visPlayers.append(otherPlayer)
                }
            }

            return BoardUpdate(nodes: visNodes, players: visPlayers, player: player)
        }

        return nil
    }

}

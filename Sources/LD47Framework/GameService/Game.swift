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
    var nodeMap: [UInt16] = []
    var nodes: [Node] = []
    var players: [String: Player] = [:]

    init() {

    }

    init(_ seed: Int, _ numNodes: Int) {
        generate(seed, numNodes)
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

            nodesNear(playerNode.x, playerNode.y, visWidth/2, visHeight/2, &visNodes)

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

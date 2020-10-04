import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// The network of nodes is a tight array of nodes, each node
// has a X/Y position and can contain up to four connections
// to other nodes. d is the distance needed to travel from
// here to the exit.  The exit is always node 0.

struct BoardUpdate: Codable {
    var tag: String = "BoardUpdate"
    var nodes: [Node]
    var players: [Player]
    var player: Player?

    var scores: [Int]

    var eventPlayerKills: [EventPlayerKill]?
    var eventPlayerBonuses: [EventPlayerBonus]?
}

struct PlayerInfo: Codable {
    var tag: String = "PlayerInfo"
    var player: Player
}

class Game {
    let kScorePerPlayerKill = 5
    let kScorePerPlayerExit = 150

    var nodeMap: [UInt16] = []
    var nodes: [Node] = []
    var players: [String: Player] = [:]

    var scores: [Int] = [0, 0, 0, 0]

    let rng: Randomable = Xoroshiro128Plus()

    var eventPlayerKills: [String: [EventPlayerKill]] = [:]
    var eventPlayerBonuses: [String: [EventPlayerBonus]] = [:]

    init() {

    }

    init(_ seed: Int, _ numNodes: Int) {
        generate(seed, numNodes)
    }

    func getSpawnIdx() -> Int {
        // find a node which is sufficiently distant from the exit node
        var spawn = nodes[0]

        for _ in 0..<100 {
            let node = rng.get(nodes)
            if node.d > spawn.d {
                spawn = node
            }
        }

        return spawn.id
    }

    func addPlayer(_ playerID: String, _ teamId: Int, _ playerName: String) -> PlayerInfo {
        if let player = players[playerID] {
            return PlayerInfo(player: player)
        }
        let player = Player(playerID, teamId, playerName)
        player.nodeIdx = getSpawnIdx()
        players[playerID] = player
        eventPlayerKills[playerID] = []
        eventPlayerBonuses[playerID] = []
        return PlayerInfo(player: player)
    }

    func removePlayer(_ playerID: String) {
        players.removeValue(forKey: playerID)
        eventPlayerKills.removeValue(forKey: playerID)
        eventPlayerBonuses.removeValue(forKey: playerID)
    }

    func recordEventPlayerKill(_ player: Player) {
        let event = EventPlayerKill(player, kScorePerPlayerKill)
        for key in eventPlayerKills.keys {
            eventPlayerKills[key]?.append(event)
        }
    }

    func recordEventPlayerBonus(_ player: Player) {
        let event = EventPlayerBonus(player, kScorePerPlayerKill)
        for key in eventPlayerBonuses.keys {
            eventPlayerBonuses[key]?.append(event)
        }
    }

    func getBoardUpdate(_ playerNode: Node, _ visWidth: Int, _ visHeight: Int) -> BoardUpdate? {
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

        return BoardUpdate(nodes: visNodes, players: visPlayers, player: nil, scores: scores)
    }

    func getBoardUpdate(_ playerID: String, _ visWidth: Int, _ visHeight: Int) -> BoardUpdate? {
        // 0. find the player's node
        if let player = players[playerID] {
            if var update = getBoardUpdate(nodes[player.nodeIdx], visWidth, visHeight) {
                update.player = player

                update.eventPlayerKills = eventPlayerKills[player.id]
                eventPlayerKills[player.id]?.removeAll(keepingCapacity: true)

                update.eventPlayerBonuses = eventPlayerBonuses[player.id]
                eventPlayerBonuses[player.id]?.removeAll(keepingCapacity: true)

                return update
            }
        }
        return getBoardUpdate(nodes[0], visWidth, visHeight)
    }

    func movePlayer(_ playerID: String, _ nodeIdx: Int, _ visWidth: Int, _ visHeight: Int) -> BoardUpdate? {
        if let player = players[playerID] {
            let playerNode = nodes[player.nodeIdx]

            // the player may only move to a node which is adjacent to the player's current node
            if playerNode.c.contains(nodeIdx) == false {
                return nil
            }

            // is there another player on this node...
            for other in players.values {
                if other.nodeIdx == nodeIdx && other.teamId != player.teamId {
                    // we need to destroy this other player!

                    scores[player.teamId] += kScorePerPlayerKill

                    recordEventPlayerKill(other)

                    removePlayer(other.id)
                }
            }

            player.nodeIdx = nodeIdx

            // did we reach the exit? it would be nice if the user had to sit on it or something...
            if nodeIdx == 0 {
                scores[player.teamId] += kScorePerPlayerExit
                recordEventPlayerBonus(player)
                player.nodeIdx = getSpawnIdx()
            }

            // If we moved the player, then we should send back an updated gameboard
            return getBoardUpdate(playerID, visWidth, visHeight)
        }

        return nil
    }

}

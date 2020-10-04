import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable function_parameter_count

// The network of nodes is a tight array of nodes, each node
// has a X/Y position and can contain up to four connections
// to other nodes. d is the distance needed to travel from
// here to the exit.  The exit is always node 0.

let kTransitTime: Double = 0.57

#if DEBUG
let kResetScoreTotal = 500
#else
let kResetScoreTotal = 10_000
#endif

struct BoardUpdate: Codable {
    var tag: String = "BoardUpdate"
    var transitTime: Double = kTransitTime

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

class Game: Actor {
    private let kScorePerPlayerKill = 5
    private let kScorePerPlayerExit = 150

    public var unsafeGameOver: Bool = false

    public var safeNodeMap: [UInt16] = []
    public var safeNodes: [Node] = []
    public var safePlayers: [String: Player] = [:]

    public var safeBots: [Bot] = []

    private var scores: [Int] = [0, 0, 0, 0]

    public var safeMaxNodeDistance = 0

    private let rng: Randomable = Xoroshiro256StarStar()

    private var eventPlayerKills: [String: [EventPlayerKill]] = [:]
    private var eventPlayerBonuses: [String: [EventPlayerBonus]] = [:]

    override init() {
        super.init()
    }

    init(_ seed: Int, _ numNodes: Int, _ numBots: Int) {
        super.init()

        safeGenerate(seed, numNodes)

        for _ in 0..<numBots {
            safeBots.append(Bot(self, rng.get()))
        }
    }

    private func getSpawnIdx() -> Int {
        // spawn far enough away from the exit for it to be fun
        let minSpawnDistance = Int((Float(safeMaxNodeDistance) * 0.80))
        for _ in 0..<200 {
            let node = rng.get(safeNodes)
            if node.d >= minSpawnDistance {
                return node.id
            }
        }
        return safeNodes.count-1
    }

    private func _beAddPlayer(_ playerID: String,
                              _ teamId: Int,
                              _ playerName: String,
                              _ isBot: Bool) -> PlayerInfo? {
        if unsafeGameOver {
            return nil
        }

        if let player = safePlayers[playerID] {
            return PlayerInfo(player: player)
        }
        let player = Player(playerID, teamId, playerName, isBot)
        player.nodeIdx = getSpawnIdx()

        let playerNode = safeNodes[player.nodeIdx]
        registerPlayerMove(player, playerNode.d)

        player.immune = true

        safePlayers[playerID] = player
        eventPlayerKills[playerID] = []
        eventPlayerBonuses[playerID] = []
        return PlayerInfo(player: player)
    }

    private func _beRemovePlayer(_ playerID: String) {
        safePlayers.removeValue(forKey: playerID)
        eventPlayerKills.removeValue(forKey: playerID)
        eventPlayerBonuses.removeValue(forKey: playerID)
    }

    private func recordEventPlayerKill(_ player: Player) {
        let event = EventPlayerKill(player, kScorePerPlayerKill)
        for key in eventPlayerKills.keys {
            eventPlayerKills[key]?.append(event)
        }
    }

    private func recordEventPlayerBonus(_ player: Player) {
        let event = EventPlayerBonus(player, kScorePerPlayerKill)
        for key in eventPlayerBonuses.keys {
            eventPlayerBonuses[key]?.append(event)
        }
    }

    private func getBoardUpdate(_ playerNode: Node, _ visWidth: Int, _ visHeight: Int) -> BoardUpdate? {
        // 1. only include nodes and players which are visible to this player
        var visNodes: [Int: Node] = [:]
        var visPlayers: [Player] = []

        safeNodesNear(playerNode.x, playerNode.y, visWidth/2, visHeight/2, &visNodes)

        // 2. run back through the nodes, add any nodes which are connected to a visNode
        for node in visNodes.values {
            for neighborIdx in node.c where visNodes[neighborIdx] == nil {
                visNodes[neighborIdx] = safeNodes[neighborIdx]
            }
        }

        // add players who are visible
        for otherPlayer in safePlayers.values {
            let otherPlayerNode = safeNodes[otherPlayer.nodeIdx]

            // include "immune" players as this will allow players flying across the map
            // because they found the exit to be visible
            if  (abs(otherPlayerNode.x - playerNode.x) < visWidth &&
                abs(otherPlayerNode.y - playerNode.y) < visHeight) ||
                otherPlayer.immune {
                visPlayers.append(otherPlayer)
            }
        }

        return BoardUpdate(nodes: Array(visNodes.values), players: visPlayers, player: nil, scores: scores)
    }

    private func getBoardUpdate(_ playerID: String, _ visWidth: Int, _ visHeight: Int) -> BoardUpdate? {
        // 0. find the player's node
        if let player = safePlayers[playerID] {
            if var update = getBoardUpdate(safeNodes[player.nodeIdx], visWidth, visHeight) {
                update.player = player

                update.eventPlayerKills = eventPlayerKills[player.id]
                eventPlayerKills[player.id]?.removeAll(keepingCapacity: true)

                update.eventPlayerBonuses = eventPlayerBonuses[player.id]
                eventPlayerBonuses[player.id]?.removeAll(keepingCapacity: true)

                return update
            }
        }
        return getBoardUpdate(safeNodes[0], visWidth, visHeight)
    }

    private func _beGetBoardUpdate(_ playerID: String, _ visWidth: Int, _ visHeight: Int) -> BoardUpdate? {
        return getBoardUpdate(playerID, visWidth, visHeight)
    }

    private func _beMovePlayer(_ playerID: String, _ nodeIdx: Int, _ visWidth: Int, _ visHeight: Int) -> BoardUpdate? {
        if let player = safePlayers[playerID] {
            let playerNode = safeNodes[player.nodeIdx]
            let nextNode = safeNodes[nodeIdx]

            // the player may not move when they are in transit
            if player.inTransit {
                return nil
            }

            // the player may not "move" to the exact same spot
            if player.nodeIdx == nodeIdx {
                return nil
            }

            // the player may only move to a node which is adjacent to the player's current node
            if playerNode.c.contains(nodeIdx) == false {
                return nil
            }

            player.hint = ""
            player.nodeIdx = nodeIdx
            player.inTransit = true

            registerPlayerMove(player, nextNode.d)

            Flynn.Timer(timeInterval: kTransitTime, repeats: false, self) { (_) in
                self.completePlayerTransit(player)
            }

            // If we moved the player, then we should send back an updated gameboard
            return getBoardUpdate(playerID, visWidth, visHeight)
        }

        return nil
    }

    private func registerPlayerMove(_ player: Player, _ distance: Int) {
        player.playerDidMove(distance)

        if player.isBot == false {
            Flynn.Timer(timeInterval: 1.0, repeats: false, self) { (_) in player.updateHint() }
            Flynn.Timer(timeInterval: 2.0, repeats: false, self) { (_) in player.updateHint() }
            Flynn.Timer(timeInterval: 3.0, repeats: false, self) { (_) in player.updateHint() }
            Flynn.Timer(timeInterval: 4.0, repeats: false, self) { (_) in player.updateHint() }
            Flynn.Timer(timeInterval: 5.0, repeats: false, self) { (_) in player.updateHint() }
            Flynn.Timer(timeInterval: 6.0, repeats: false, self) { (_) in player.updateHint() }
            Flynn.Timer(timeInterval: 7.0, repeats: false, self) { (_) in player.updateHint() }
            Flynn.Timer(timeInterval: 8.0, repeats: false, self) { (_) in player.updateHint() }
        }
    }

    private func completePlayerTransit(_ player: Player) {
        player.inTransit = false

        // is there another player on this node, not in transit, not immune, and a member of another team?
        for other in safePlayers.values where
            other.immune == false &&
            other.nodeIdx == player.nodeIdx &&
            other.teamId != player.teamId &&
            other.inTransit == false {

            // we need to destroy this other player!
            scores[player.teamId] += kScorePerPlayerKill
            recordEventPlayerKill(other)
            _beRemovePlayer(other.id)
        }

        // did we reach the exit? it would be nice if the user had to sit on it or something...
        if player.nodeIdx == 0 {
            scores[player.teamId] += kScorePerPlayerExit
            recordEventPlayerBonus(player)
            player.nodeIdx = getSpawnIdx()

            let playerNode = safeNodes[player.nodeIdx]
            registerPlayerMove(player, playerNode.d)

            player.immune = true
        }

        // check for game over
        for score in scores where score >= kResetScoreTotal {
            // Ok... how do we go about resetting?

            // 0. flag this game as being over
            unsafeGameOver = true

            // 1. remove all players
            for player in safePlayers.values {
                _beRemovePlayer(player.id)
            }

            safeBots.removeAll()

            // Don't allow people to join a game which is over, trust in
            // the game service to create a new game and replace this one
        }
    }

}

// MARK: - Autogenerated by FlynnLint
// Contents of file after this marker will be overwritten as needed

extension Game {

    @discardableResult
    public func beAddPlayer(_ playerID: String,
                            _ teamId: Int,
                            _ playerName: String,
                            _ isBot: Bool,
                            _ sender: Actor,
                            _ callback: @escaping ((PlayerInfo?) -> Void)) -> Self {
        unsafeSend {
            let result = self._beAddPlayer(playerID, teamId, playerName, isBot)
            sender.unsafeSend { callback(result) }
        }
        return self
    }
    @discardableResult
    public func beRemovePlayer(_ playerID: String) -> Self {
        unsafeSend { self._beRemovePlayer(playerID) }
        return self
    }
    @discardableResult
    public func beGetBoardUpdate(_ playerID: String,
                                 _ visWidth: Int,
                                 _ visHeight: Int,
                                 _ sender: Actor,
                                 _ callback: @escaping ((BoardUpdate?) -> Void)) -> Self {
        unsafeSend {
            let result = self._beGetBoardUpdate(playerID, visWidth, visHeight)
            sender.unsafeSend { callback(result) }
        }
        return self
    }
    @discardableResult
    public func beMovePlayer(_ playerID: String,
                             _ nodeIdx: Int,
                             _ visWidth: Int,
                             _ visHeight: Int,
                             _ sender: Actor,
                             _ callback: @escaping ((BoardUpdate?) -> Void)) -> Self {
        unsafeSend {
            let result = self._beMovePlayer(playerID, nodeIdx, visWidth, visHeight)
            sender.unsafeSend { callback(result) }
        }
        return self
    }

}

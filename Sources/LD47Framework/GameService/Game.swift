import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable identifier_name
// swiftlint:disable function_parameter_count
// swiftlint:disable file_length
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length

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

class Game: Actor {
    private let kScorePerPlayerKill = 5
    private let kScorePerPlayerExit = 150

    private var nodeMap: [UInt16] = []
    private var nodes: [Node] = []
    private var players: [String: Player] = [:]

    private var scores: [Int] = [0, 0, 0, 0]

    private let rng: Randomable = Xoroshiro128Plus()

    private var eventPlayerKills: [String: [EventPlayerKill]] = [:]
    private var eventPlayerBonuses: [String: [EventPlayerBonus]] = [:]

    override init() {
        super.init()
    }

    init(_ seed: Int, _ numNodes: Int) {
        super.init()

        generate(seed, numNodes)
    }

    private func getSpawnIdx() -> Int {
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

    private func _beAddPlayer(_ playerID: String, _ teamId: Int, _ playerName: String) -> PlayerInfo {
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

    private func _beRemovePlayer(_ playerID: String) {
        players.removeValue(forKey: playerID)
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

    private func getBoardUpdate(_ playerID: String, _ visWidth: Int, _ visHeight: Int) -> BoardUpdate? {
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

    private func _beGetBoardUpdate(_ playerID: String, _ visWidth: Int, _ visHeight: Int) -> BoardUpdate? {
        return getBoardUpdate(playerID, visWidth, visHeight)
    }

    private func _beMovePlayer(_ playerID: String, _ nodeIdx: Int, _ visWidth: Int, _ visHeight: Int) -> BoardUpdate? {
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

                    _beRemovePlayer(other.id)
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

    // MARK: BOARD STUFF

    private func connect(_ a: Node, _ b: Node) {
        a.to(b.id)
        b.to(a.id)
    }

    @inline(__always)
    private func mapIdx(_ x: Int, _ y: Int) -> Int? {
        let mapIdx = y * kMaxMapSize + x
        if mapIdx >= 0 && mapIdx < (kMaxMapSize*kMaxMapSize) {
            return mapIdx
        }
        return nil
    }

    private func nodesNear(_ x: Int, _ y: Int, _ cx: Int, _ cy: Int, _ nearNodes: inout [Node]) {
        nearNodes.removeAll(keepingCapacity: true)

        var nearNodesFast: [Int: Node] = [:]

        for mapX in x-cx..<x+cx {
            for mapY in y-cy..<y+cy {
                if let idx = mapIdx(mapX, mapY) {
                    if idx != 0 {
                        let nearNodeIdx = Int(nodeMap[idx])
                        if nearNodeIdx != kNoNode {
                            let nearNode = nodes[nearNodeIdx]
                            if nearNodesFast[nearNodeIdx] == nil {
                                nearNodesFast[nearNodeIdx] = nearNode
                            }
                        }
                    }
                }
            }
        }

        for node in nearNodesFast.values {
            nearNodes.append(node)
        }
    }

    private func mark(_ x: Int, _ y: Int, _ id: Int) {
        // mark the spots on the map that are now invalid
        for mapX in x-6..<x+6 {
            for mapY in y-6..<y+6 {
                if let idx = mapIdx(mapX, mapY) {
                    nodeMap[idx] = UInt16(id)
                }
            }
        }
    }

    private func generate(_ seed: Int, _ targetNodes: Int) {
        let rng: Randomable = Xoroshiro128Plus("\(seed)")

        nodeMap = [UInt16](repeating: UInt16(kNoNode), count: kMaxMapSize * kMaxMapSize)

        nodes.removeAll()
        players.removeAll()

        var openNodes: [Node] = []

        // start with exit node (always index 0)
        let exitNode = Node(0, kMaxMapSize / 2, kMaxMapSize / 2)
        exitNode.d = 0
        nodes.append(exitNode)
        openNodes.append(exitNode)

        mark(exitNode.x, exitNode.y, exitNode.id)

        // until we have enough nodes
        while nodes.count < targetNodes {

            // choose a random node from the open nodes
            let parentNode = rng.get(openNodes)

            // if we chose a node that's already full, remove it from the open nodes
            if parentNode.c.count >= kMaxConnections {
                openNodes.removeAll(parentNode)
                continue
            }

            // choose a random offset from this node
            var x = 0
            var y = 0
            var valid = false
            for _ in 0..<100 {
                x = rng.get(min: -10, max: 10) + parentNode.x
                y = rng.get(min: -10, max: 10) + parentNode.y

                // check to see if this spot is clear (make sure we're not
                // too close to any other existing node
                if let idx = mapIdx(x, y) {
                    if nodeMap[idx] == kNoNode {
                        valid = true
                        break
                    }
                }
            }

            // if we didn't find a valid spot after 100 tries, list this not open
            if !valid {
                openNodes.removeAll(parentNode)
                continue
            }

            let newNode = Node(nodes.count, x, y)
            nodes.append(newNode)
            openNodes.append(newNode)

            // mark the spots on the map that are now invalid
            mark(x, y, newNode.id)

            // add connections for this node. if we always connect to our parent, then we know we will
            // always be able to reach the exit
            connect(parentNode, newNode)

            if nodes.count % 50 == 0 {
                print("A: \(nodes.count) of \(targetNodes)")
            }
        }

        // run through all nodes and add a little interconnected-ness
        var nearNodes: [Node] = []

        var nodeCount = 0
        for node in nodes {

            nodeCount += 1
            if nodeCount % 50 == 0 {
                print("B: \(nodeCount) of \(targetNodes)")
            }

            if node.c.count > kMaxConnections {
                continue
            }

            nodesNear(node.x, node.y, 8, 8, &nearNodes)

            for other in nearNodes {
                if node.c.count > kMaxConnections {
                    break
                }
                if other.c.count > kMaxConnections {
                    continue
                }

                if rng.maybe(0.2) {
                    connect(node, other)
                }
            }
        }

        // perform distance calculations so all nodes know how far they are from the exit
        solve()

    }

    private func solve() {
        var changed = true
        while changed {
            changed = false

            if transformForward() {
                changed = true
            }
            if transformBackward() {
                changed = true
            }
        }
    }

    private func transformForward() -> Bool {
        var changed = false
        for node in nodes where node.d > 0 {
            for nextIdx in node.c {
                let next = nodes[nextIdx]
                if next.d >= 0 && next.d+1 < node.d {
                    node.d = next.d+1
                    changed = true
                }
            }
        }
        return changed
    }

    private func transformBackward() -> Bool {
        var changed = false
        for node in nodes.reversed() where node.d > 0 {
            for nextIdx in node.c {
                let next = nodes[nextIdx]
                if next.d >= 0 && next.d+1 < node.d {
                    node.d = next.d+1
                    changed = true
                }
            }
        }
        return changed
    }

}

// MARK: - Autogenerated by FlynnLint
// Contents of file after this marker will be overwritten as needed

extension Game {

    @discardableResult
    public func beAddPlayer(_ playerID: String,
                            _ teamId: Int,
                            _ playerName: String,
                            _ sender: Actor,
                            _ callback: @escaping ((PlayerInfo) -> Void)) -> Self {
        unsafeSend {
            let result = self._beAddPlayer(playerID, teamId, playerName)
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

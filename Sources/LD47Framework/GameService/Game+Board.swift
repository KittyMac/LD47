import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable identifier_name
// swiftlint:disable cyclomatic_complexity

typealias NodeIndex = Int
let kNoNode: NodeIndex = 32767

let kMaxDistance: Int = 32767

let kMaxConnections: Int = 4

let kMaxMapSize = 20_000

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

    @discardableResult
    func to(_ other: Int) -> Self {
        if c.contains(other) == false {
            c.append(other)
        }
        return self
    }
}

extension Game {

    func connect(_ a: Node, _ b: Node) {
        a.to(b.id)
        b.to(a.id)
    }

    @inline(__always)
    func mapIdx(_ x: Int, _ y: Int) -> Int? {
        let mapIdx = y * kMaxMapSize + x
        if mapIdx >= 0 && mapIdx < (kMaxMapSize*kMaxMapSize) {
            return mapIdx
        }
        return nil
    }

    func nodesNear(_ x: Int, _ y: Int, _ cx: Int, _ cy: Int, _ nearNodes: inout [Node]) {
        nearNodes.removeAll(keepingCapacity: true)

        var nearNodesFast: [Int: Node] = [:]

        for mapX in x-cx..<x+cx {
            for mapY in y-cy..<y+cy {
                if let idx = mapIdx(mapX, mapY) {
                    if idx != 0 {
                        let nearNodeIdx = Int(nodeMap[idx])
                        let nearNode = nodes[nearNodeIdx]
                        if nearNodesFast[nearNodeIdx] == nil {
                            nearNodesFast[nearNodeIdx] = nearNode
                        }
                    }
                }
            }
        }

        for node in nearNodesFast.values {
            nearNodes.append(node)
        }
    }

    func generate(_ seed: Int, _ targetNodes: Int) {
        let rng: Randomable = Xoroshiro128Plus("\(seed)")

        nodeMap = [UInt16](repeating: 0, count: kMaxMapSize * kMaxMapSize)

        nodes.removeAll()
        players.removeAll()

        var openNodes: [Node] = []

        // start with exit node (always index 0)
        let exitNode = Node(0, kMaxMapSize / 2, kMaxMapSize / 2)
        nodes.append(exitNode)
        openNodes.append(exitNode)

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
                    if nodeMap[idx] == 0 {
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
            for mapX in x-6..<x+6 {
                for mapY in y-6..<y+6 {
                    if let idx = mapIdx(mapX, mapY) {
                        nodeMap[idx] = UInt16(newNode.id)
                    }
                }
            }

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

        // nodes.append(Node(0, 0, 0).to(1).to(6))
    }

}

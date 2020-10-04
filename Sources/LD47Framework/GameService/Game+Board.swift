import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable identifier_name
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length

typealias NodeIndex = Int
let kNoNode: NodeIndex = Int(UInt16.max)

let kMaxDistance: Int = 32767

let kMaxConnections: Int = 4

let kMaxMapSize = 6_000

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

    public func safeNodesNear(_ x: Int, _ y: Int, _ cx: Int, _ cy: Int, _ nearNodes: inout [Int: Node]) {
        nearNodes.removeAll(keepingCapacity: true)

        var lastNodeIdxAdded: UInt16 = UInt16.max
        for mapX in x-cx..<x+cx {
            for mapY in y-cy..<y+cy {
                if let idx = mapIdx(mapX, mapY) {
                    if idx != 0 {
                        let nearNodeIdx = safeNodeMap[idx]
                        if nearNodeIdx != lastNodeIdxAdded && nearNodeIdx != kNoNode {
                            lastNodeIdxAdded = nearNodeIdx

                            let nearNodeIdxAsInt = Int(nearNodeIdx)
                            nearNodes[nearNodeIdxAsInt] = safeNodes[nearNodeIdxAsInt]
                        }
                    }
                }
            }
        }
    }

    private func mark(_ x: Int, _ y: Int, _ id: Int) {
        // mark the spots on the map that are now invalid
        for mapX in x-6..<x+6 {
            for mapY in y-6..<y+6 {
                if let idx = mapIdx(mapX, mapY) {
                    safeNodeMap[idx] = UInt16(id)
                }
            }
        }
    }

    public func safeGenerate(_ seed: Int, _ targetNodes: Int) {
        let rng: Randomable = Xoroshiro256StarStar("\(seed)")

        safeNodeMap = [UInt16](repeating: UInt16(kNoNode), count: kMaxMapSize * kMaxMapSize)

        safeNodes.removeAll()
        safePlayers.removeAll()

        var openNodes: [Node] = []

        // start with exit node (always index 0)
        let exitNode = Node(0, kMaxMapSize / 2, kMaxMapSize / 2)
        exitNode.d = 0
        safeNodes.append(exitNode)
        openNodes.append(exitNode)

        mark(exitNode.x, exitNode.y, exitNode.id)

        // until we have enough nodes
        while safeNodes.count < targetNodes {

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
                    if safeNodeMap[idx] == kNoNode {
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

            let newNode = Node(safeNodes.count, x, y)
            safeNodes.append(newNode)
            openNodes.append(newNode)

            // mark the spots on the map that are now invalid
            mark(x, y, newNode.id)

            // add connections for this node. if we always connect to our parent, then we know we will
            // always be able to reach the exit
            connect(parentNode, newNode)

            if safeNodes.count % 50 == 0 {
                print("A: \(safeNodes.count) of \(targetNodes)")
            }
        }

        // run through all nodes and add a little interconnected-ness
        var nearNodes: [Int: Node] = [:]

        var nodeCount = 0
        for node in safeNodes {

            nodeCount += 1
            if nodeCount % 50 == 0 {
                print("B: \(nodeCount) of \(targetNodes)")
            }

            if node.c.count > kMaxConnections {
                continue
            }

            safeNodesNear(node.x, node.y, 8, 8, &nearNodes)

            for other in nearNodes.values {
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

        safeMaxNodeDistance = 0
        for node in safeNodes where node.d > safeMaxNodeDistance {
            safeMaxNodeDistance = node.d
        }
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
        for node in safeNodes where node.d > 0 {
            for nextIdx in node.c {
                let next = safeNodes[nextIdx]
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
        for node in safeNodes.reversed() where node.d > 0 {
            for nextIdx in node.c {
                let next = safeNodes[nextIdx]
                if next.d >= 0 && next.d+1 < node.d {
                    node.d = next.d+1
                    changed = true
                }
            }
        }
        return changed
    }
}

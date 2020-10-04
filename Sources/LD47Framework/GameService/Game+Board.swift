import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable identifier_name

typealias NodeIndex = Int
let kNoNode: NodeIndex = Int(UInt16.max)

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

import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

class Bot: Actor {
    // multiplayer games without people to play with is BOOOORRING.  Need to add
    // some bots in order to make this little world more fun!

    // A bot in this game should act like any other player; meaning they should not gain
    // any special priviledges (such as advanced sight). They should interact using the
    // same APIs that players do.

    private let game: Game
    private var playerName: String
    private var rng: Randomable
    private let visRange = 65

    init(_ game: Game, _ seed: UInt64) {
        self.game = game
        self.playerName = ""
        self.rng = Xoroshiro256StarStar(seed)
        super.init()

        self.playerName = "BOT"

        // stagger bot start times to avoid large spikes in activity
        Flynn.Timer(timeInterval: Double(rng.get(min: 1.0, max: 10.0)), repeats: false, self) { (_) in
            Flynn.Timer(timeInterval: kTransitTime + 0.3, repeats: true, self) { (_) in
                game.beGetBoardUpdate(self.unsafeUUID, self.visRange, self.visRange, self) { (board) in
                    if let board = board {
                        if let player = board.player {
                            self.performTurn(player, board)
                        } else {
                            self.joinGame(board)
                        }
                    }
                }
            }
        }
    }

    private func getNodeById(_ nodeIdx: Int, _ board: BoardUpdate) -> Node? {
        for node in board.nodes where node.id == nodeIdx {
            return node
        }
        return nil
    }

    private func joinGame(_ board: BoardUpdate) {
        game.beAddPlayer(unsafeUUID, rng.get(min: 0, max: 3), playerName, true, self) { (_) in }
    }

    private func performTurn(_ player: Player, _ board: BoardUpdate) {
        if rng.maybe(0.2) {
            doNothing(player, board)
        } else {
            moveRandom(player, board)
        }
    }

    private func moveRandom(_ player: Player, _ board: BoardUpdate) {
        if let playerNode = getNodeById(player.nodeIdx, board) {
            let nextNodeIdx = rng.get(playerNode.c)
            game.beMovePlayer(unsafeUUID, nextNodeIdx, visRange, visRange, self) { (_) in }
        }
    }

    private func doNothing(_ player: Player, _ board: BoardUpdate) {

    }

}

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
    private var rng: Randomable = Xoroshiro128Plus(UInt64.random(in: 0...100000))
    private let visRange = 70

    init(_ game: Game) {
        self.game = game
        self.playerName = ""
        super.init()

        self.playerName = "\(self)"

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

        //_beAddPlayer(unsafeUUID, _ teamId: Int, playerName)
    }

    private func getNodeById(_ nodeIdx: Int, _ board: BoardUpdate) -> Node? {
        for node in board.nodes where node.id == nodeIdx {
            return node
        }
        return nil
    }

    private func joinGame(_ board: BoardUpdate) {
        // TODO: Bots should favor joining the losing teams. Do this by given each team an inverse chance for a ticket in the raffle
        game.beAddPlayer(unsafeUUID, rng.get(min: 0, max: 3), playerName, self) { (_) in }
    }

    private func performTurn(_ player: Player, _ board: BoardUpdate) {
        // TODO: Bots should behave at least somewhat intelligently; for now, we're just doing random things!
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

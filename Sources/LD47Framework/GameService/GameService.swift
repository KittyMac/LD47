import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable function_parameter_count

class GameService: RemoteActor {
    static let serviceName = "LD47_GAME_SERVICE"

    private var game: Game?

    override func safeInit() {
#if DEBUG
        game = Game(42, 50, 4)
#else
        game = Game(42, 10000, 150)
#endif
    }

    private func _bePlayerJoin(_ playerID: String,
                               _ teamId: Int,
                               _ playerName: String,
                               _ returnCallback: @escaping (String) -> Void) {

        if let game = game {
            game.beAddPlayer(playerID, teamId, playerName, Flynn.any) {
                returnCallback((try? $0.json()) ?? "")
            }
        } else {
            returnCallback("")
        }
    }

    private func _beGetBoard(_ playerID: String,
                             _ visWidth: Int,
                             _ visHeight: Int,
                             _ returnCallback: @escaping (String) -> Void) {
        if let game = game {
            game.beGetBoardUpdate(playerID, visWidth, visHeight, Flynn.any) {
                returnCallback((try? $0.json()) ?? "")
            }
        } else {
            returnCallback("")
        }
    }

    private func _beMovePlayer(_ playerID: String,
                               _ nodeIdx: Int,
                               _ visWidth: Int,
                               _ visHeight: Int,
                               _ returnCallback: @escaping (String) -> Void) {
        if let game = game {
            game.beMovePlayer(playerID, nodeIdx, visWidth, visHeight, Flynn.any) {
                returnCallback((try? $0.json()) ?? "")
            }
        } else {
            returnCallback("")
        }
    }
}

// MARK: - Autogenerated by FlynnLint
// Contents of file after this marker will be overwritten as needed

extension GameService {

    struct BePlayerJoinCodableResponse: Codable {
        let response: String
    }
    struct BePlayerJoinCodableRequest: Codable {
        let arg0: String
        let arg1: Int
        let arg2: String
    }
    struct BeGetBoardCodableResponse: Codable {
        let response: String
    }
    struct BeGetBoardCodableRequest: Codable {
        let arg0: String
        let arg1: Int
        let arg2: Int
    }
    struct BeMovePlayerCodableResponse: Codable {
        let response: String
    }
    struct BeMovePlayerCodableRequest: Codable {
        let arg0: String
        let arg1: Int
        let arg2: Int
        let arg3: Int
    }

    @discardableResult
    public func bePlayerJoin(_ playerID: String,
                             _ teamId: Int,
                             _ playerName: String,
                             _ sender: Actor,
                             _ callback: @escaping (String) -> Void ) -> Self {
        let msg = BePlayerJoinCodableRequest(arg0: playerID, arg1: teamId, arg2: playerName)
        // swiftlint:disable:next force_try
        let data = try! JSONEncoder().encode(msg)
        unsafeSendToRemote("GameService", "bePlayerJoin", data, sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! JSONDecoder().decode(BePlayerJoinCodableResponse.self, from: $0).response)
            )
        }
        return self
    }
    @discardableResult
    public func beGetBoard(_ playerID: String,
                           _ visWidth: Int,
                           _ visHeight: Int,
                           _ sender: Actor,
                           _ callback: @escaping (String) -> Void ) -> Self {
        let msg = BeGetBoardCodableRequest(arg0: playerID, arg1: visWidth, arg2: visHeight)
        // swiftlint:disable:next force_try
        let data = try! JSONEncoder().encode(msg)
        unsafeSendToRemote("GameService", "beGetBoard", data, sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! JSONDecoder().decode(BeGetBoardCodableResponse.self, from: $0).response)
            )
        }
        return self
    }
    @discardableResult
    public func beMovePlayer(_ playerID: String,
                             _ nodeIdx: Int,
                             _ visWidth: Int,
                             _ visHeight: Int,
                             _ sender: Actor,
                             _ callback: @escaping (String) -> Void ) -> Self {
        let msg = BeMovePlayerCodableRequest(arg0: playerID, arg1: nodeIdx, arg2: visWidth, arg3: visHeight)
        // swiftlint:disable:next force_try
        let data = try! JSONEncoder().encode(msg)
        unsafeSendToRemote("GameService", "beMovePlayer", data, sender) {
            callback(
                // swiftlint:disable:next force_try
                (try! JSONDecoder().decode(BeMovePlayerCodableResponse.self, from: $0).response)
            )
        }
        return self
    }

    public func unsafeRegisterAllBehaviors() {
        safeRegisterDelayedRemoteBehavior("bePlayerJoin") { [unowned self] (data, callback) in
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BePlayerJoinCodableRequest.self, from: data)
            self._bePlayerJoin(msg.arg0, msg.arg1, msg.arg2) { (returnValue: String) in
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BePlayerJoinCodableResponse(response: returnValue))
                )
            }
        }
        safeRegisterDelayedRemoteBehavior("beGetBoard") { [unowned self] (data, callback) in
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeGetBoardCodableRequest.self, from: data)
            self._beGetBoard(msg.arg0, msg.arg1, msg.arg2) { (returnValue: String) in
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeGetBoardCodableResponse(response: returnValue))
                )
            }
        }
        safeRegisterDelayedRemoteBehavior("beMovePlayer") { [unowned self] (data, callback) in
            // swiftlint:disable:next force_try
            let msg = try! JSONDecoder().decode(BeMovePlayerCodableRequest.self, from: data)
            self._beMovePlayer(msg.arg0, msg.arg1, msg.arg2, msg.arg3) { (returnValue: String) in
                callback(
                    // swiftlint:disable:next force_try
                    try! JSONEncoder().encode(
                        BeMovePlayerCodableResponse(response: returnValue))
                )
            }
        }
    }
}

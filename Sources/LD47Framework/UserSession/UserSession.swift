import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable identifier_name
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length
// swiftlint:disable line_length

public class LD47UserSession: UserSession {

    private var timeIntervalOfLastUpdate: TimeInterval = 0.0
    private var firstUpdate = true
    private var lastVisibleBoardWidth: Int = 100
    private var lastVisibleBoardHeight: Int = 100

    public override func safeHandleRequest(_ connection: AnyConnection, _ httpRequest: HttpRequest) {
        switch httpRequest.flynnTag {
        case "GetBoard":

            if firstUpdate {
                connection.beSetTimeout(60 * 5)
                firstUpdate = false
            }

            struct GetBoardRequest: Codable {
                let w: Float
                let h: Float
            }

            if let request: GetBoardRequest = try? httpRequest.content?.decoded() {

                lastVisibleBoardWidth = Int(request.w)
                lastVisibleBoardHeight = Int(request.h)

                // We want to rate limit the gameboard updates to only allow 10 updates
                // per second. However, we don't want to penalize users for lag.
                //let timeToWait = max(min(0.1 - (ProcessInfo.processInfo.systemUptime - timeIntervalOfLastUpdate), 0.1), 0)
                let timeToWait = 0.1
                Flynn.Timer(timeInterval: timeToWait, repeats: false, self) { (_) in
                    //self.timeIntervalOfLastUpdate = ProcessInfo.processInfo.systemUptime

                    Flynn.Root.remoteActorByUUID(GameService.serviceName, self) {
                        if let game = $0 as? GameService {
                            game.beGetBoard(self.unsafeSessionUUID,
                                            self.lastVisibleBoardWidth,
                                            self.lastVisibleBoardHeight,
                                            self) {
                                connection.beSendData(HttpResponse.asData(self, .ok, .txt, $0))
                            }
                        }
                    }
                }
            }

        case "PlayerJoin":

            struct PlayerJoinRequest: Codable {
                let playerName: String
                let teamId: Int
            }

            if let request: PlayerJoinRequest = try? httpRequest.content?.decoded() {
                Flynn.Root.remoteActorByUUID(GameService.serviceName, self) {
                    if let game = $0 as? GameService {
                        game.bePlayerJoin(self.unsafeSessionUUID,
                                          request.teamId,
                                          String(request.playerName.prefix(32)),
                                          self) {
                            connection.beSendData(HttpResponse.asData(self, .ok, .txt, $0))
                        }
                    }
                }
            }
        case "MovePlayer":

            struct PlayerMoveRequest: Codable {
                let nodeIdx: Int
            }

            if let request: PlayerMoveRequest = try? httpRequest.content?.decoded() {
                Flynn.Root.remoteActorByUUID(GameService.serviceName, self) {
                    if let game = $0 as? GameService {
                        game.beMovePlayer(self.unsafeSessionUUID,
                                          request.nodeIdx,
                                          self.lastVisibleBoardWidth,
                                          self.lastVisibleBoardHeight,
                                          self) {
                            connection.beSendData(HttpResponse.asData(self, .ok, .txt, $0))
                        }
                    }
                }
            }

        default:
            firstUpdate = true
            connection.beSendData(HttpResponse.asData(self, .ok, .html, Pamphlet.IndexHtml()))
        }
    }

}

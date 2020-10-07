import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable identifier_name
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length

public class LD47UserSession: UserSession {

    private var lastUpdateTime: TimeInterval = ProcessInfo.processInfo.systemUptime
    private var roundTripRunningAvg: TimeInterval = 0.1
    private var currentWaitTime: TimeInterval = 0.1

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

                // Our goal is to deliver updates to the user 10 times per second. To do this, we need to keep a
                // running average of the round trip time and constantly adjust our wait time so that the total
                // round trip time is 0.1 seconds
                let now = ProcessInfo.processInfo.systemUptime
                let roundTripTime = min(max(now - lastUpdateTime, 0), 1)
                self.lastUpdateTime = now

                roundTripRunningAvg = ((roundTripRunningAvg * 8.0) + roundTripTime) / 9.0

                // if roundTripRunningAvg > 0.1, then we need to reduce our wait time.  if its < 0.1, then
                // we need to increase our wait time.
                let waitTimeDelta = (0.1 - roundTripRunningAvg) * 0.125
                currentWaitTime += waitTimeDelta

                Flynn.Timer(timeInterval: currentWaitTime, repeats: false, self) { (_) in
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

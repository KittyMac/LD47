import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable identifier_name

public class LD47UserSession: UserSession {

    private var firstUpdate = true
    private var lastVisibleBoardWidth: Int = 100
    private var lastVisibleBoardHeight: Int = 100

    public override func safeHandleRequest(_ connection: AnyConnection, _ httpRequest: HttpRequest) {
        switch httpRequest.flynnTag {
        case "GetBoard":

            var waitTime = 0.1
            if firstUpdate {
                waitTime = 0.0
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

                Flynn.Timer(timeInterval: waitTime, repeats: false, self) { (_) in
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
                                          request.playerName,
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

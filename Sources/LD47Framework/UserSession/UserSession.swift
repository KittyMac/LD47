import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

// swiftlint:disable identifier_name

public class LD47UserSession: UserSession {

    private var firstUpdate = true

    public override func safeHandleRequest(_ connection: AnyConnection, _ httpRequest: HttpRequest) {

        switch httpRequest.flynnTag {
        case "GetBoard":

            var waitTime = 0.5
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
                Flynn.Timer(timeInterval: waitTime, repeats: false, self) { (_) in
                    Flynn.Root.remoteActorByUUID(GameService.serviceName, self) {
                        if let game = $0 as? GameService {
                            game.beGetBoard(self.unsafeSessionUUID, Int(request.w), Int(request.h), self) {
                                connection.beSendData(HttpResponse.asData(self, .ok, .txt, $0))
                            }
                        }
                    }
                }
            }

        case "PlayerJoin":

            struct PlayerJoinRequest: Codable {
                let playerName: String
            }

            if let request: PlayerJoinRequest = try? httpRequest.content?.decoded() {
                Flynn.Root.remoteActorByUUID(GameService.serviceName, self) {
                    if let game = $0 as? GameService {
                        game.bePlayerJoin(self.unsafeSessionUUID, request.playerName, self) {
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

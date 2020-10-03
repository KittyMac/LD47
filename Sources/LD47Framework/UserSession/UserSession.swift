import Flynn
import Foundation
import Socket
import PicaroonFramework
import Pamphlet

public class LD47UserSession: UserSession {

    public override func safeHandleRequest(_ connection: AnyConnection, _ httpRequest: HttpRequest) {

        switch httpRequest.flynnTag {
        case "GetBoard":
            connection.beSetTimeout(60 * 5)

            Flynn.Timer(timeInterval: 1.0, repeats: false, self) { (_) in
                Flynn.Root.remoteActorByUUID(GameService.serviceName, self) {
                    if let game = $0 as? GameService {
                        game.beGetBoard(self.unsafeSessionUUID, self) {
                            connection.beSendData(HttpResponse.asData(self, .ok, .txt, $0))
                        }
                    }
                }
            }
        case "PlayerJoin":
            Flynn.Root.remoteActorByUUID(GameService.serviceName, self) {
                if let game = $0 as? GameService {
                    game.bePlayerJoin(self.unsafeSessionUUID, "Robert", self) {
                        connection.beSendData(HttpResponse.asData(self, .ok, .txt, $0))
                    }
                }
            }
        default:
            connection.beSendData(HttpResponse.asData(self, .ok, .html, Pamphlet.IndexHtml()))
        }
    }

}

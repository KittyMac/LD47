import Foundation
import Flynn
import Socket
import PicaroonFramework
import Pamphlet

func handleStaticRequest(_ httpRequest: HttpRequest) -> Data? {
    if let url = httpRequest.url {
        var supportsGzip = false
        if let acceptEncoding = httpRequest.acceptEncoding {
            supportsGzip = acceptEncoding.contains("gzip")
        }

        if url.hasPrefix("/private") {
            return HttpResponse.asData(nil, .internalServerError, .txt)
        } else if let content = Pamphlet.get(gzip: url), supportsGzip {
            return HttpResponse.asData(nil, .ok, HttpContentType.fromPath(url), content, "gzip")
        } else if let content = Pamphlet.get(data: url) {
            return HttpResponse.asData(nil, .ok, HttpContentType.fromPath(url), content)
        } else if let content = Pamphlet.get(string: url) {
            return HttpResponse.asData(nil, .ok, HttpContentType.fromPath(url), content)
        }
    }
    return nil
}

public enum LD47Server {

    public static func http(_ address: String,
                            _ port: Int) {
        Connection.defaultTimeout = 60 * 5

#if DEBUG
        Flynn.Node.connect("127.0.0.1", 9090, [GameService.self], false)
        Flynn.Node.registerActorsWithRoot([GameService(GameService.serviceName)])
#endif

        Flynn.Root.listen("0.0.0.0", 9090, [GameService.self])

        Server<LD47UserSession>(address, port, handleStaticRequest).run()

    }

    public static func game(_ roots: [String]) {
        Connection.defaultTimeout = 60 * 5

        // set up the services we offer to our remotes:
        let gameService = GameService(GameService.serviceName)

        Flynn.Node.registerActorsWithRoot([gameService])

        connectToRoots(roots, [GameService.self])

        while true { sleep(99999) }
    }

    private static func connectToRoots(_ roots: [String], _ services: [RemoteActor.Type]) {
        for root in roots {
            let parts = root.split(separator: ":")
            if parts.count == 2 {
                if let port = Int32(parts[1]) {
                    let address = String(parts[0])
                    Flynn.Node.connect(address, port, services)
                }
            }
        }
    }
}

import Foundation
import LD47Framework
import ArgumentParser

struct LD47CLI: ParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Runs one of the LD47 application servers",
        subcommands: [Http.self, Game.self],
        defaultSubcommand: Http.self)

    struct Http: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Run as HTTP server")

        @Argument(help: "IP address for the server to listen on")
        var address: String = "0.0.0.0"

        @Argument(help: "TCP port for the server to listen on")
        var port: Int = 8080

        mutating func run() throws {
            LD47Server.http(address, port)
        }
    }

    struct Game: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Run as GAME server")

        @Argument(help: "List of Root IP addresses to connect to")
        var roots: [String]

        mutating func run() {
            LD47Server.game(roots)
        }
    }
}

LD47CLI.main()

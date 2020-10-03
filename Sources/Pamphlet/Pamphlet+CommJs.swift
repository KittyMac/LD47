import Foundation

// swiftlint:disable all

public extension Pamphlet {
    static func CommJs() -> String {
#if DEBUG
let filePath = "/Volumes/Development/Development/chimerasw2/LD47/Resources/comm.js"
if let contents = try? String(contentsOfFile:filePath) {
    if contents.hasPrefix("#define PAMPHLET_PREPROCESSOR") {
        do {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/local/bin/pamphlet")
            task.arguments = ["preprocess", filePath]
            let outputPipe = Pipe()
            task.standardOutput = outputPipe
            try task.run()
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(decoding: outputData, as: UTF8.self)
            return output
        } catch {
            return "Failed to use /usr/local/bin/pamphlet to preprocess the requested file"
        }
    }
    return contents
}
return "file not found"
#else
return ###"""
function gameUpdateLongPoll(callback) {    
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4) {
            if (this.status == 200) {
                callback(JSON.parse(this.responseText));
                setTimeout(function() { gameUpdateLongPoll(callback) }, 1);
            } else {
                setTimeout(function() { gameUpdateLongPoll(callback) }, 1000);
            }
            
        }
    };
    xhttp.open("POST", "/");
    xhttp.setRequestHeader("Flynn-Tag", "GetBoard");
    xhttp.setRequestHeader("Pragma", "no-cache");
    xhttp.setRequestHeader("Expires", "-1");
    xhttp.setRequestHeader("Cache-Control", "no-cache");
    xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    
    let command = {
        w: app.renderer.width / kBoardToScreen,
        h: app.renderer.height / kBoardToScreen
    };
    xhttp.send(JSON.stringify(command));
}

function sendCommand(command, callback) {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4) {
            if (this.status == 200) {
                callback(JSON.parse(this.responseText));
            }
        }
    };
    xhttp.open("POST", "/");
    xhttp.setRequestHeader("Flynn-Tag", "PlayerJoin");
    xhttp.setRequestHeader("Pragma", "no-cache");
    xhttp.setRequestHeader("Expires", "-1");
    xhttp.setRequestHeader("Cache-Control", "no-cache");
    xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhttp.send(JSON.stringify(command));
}

function registerPlayer(name, callback) {
    sendCommand({
        playerName:name
    }, callback)
}
"""###
#endif
}
}


public extension Pamphlet {
    static func CommJsGzip() -> Data {
        return gzip_data!
    }
}

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA+VUwW7bMAy9+ysInxQgTtJhh6FFLgvWFUXXBosL7KrZjK1VpjRJWWIM/vdJTrzaybCgA3bZeBAg+z2S5nv0ekOZE4qg4BU+6pw7vFNULJWULONSfubZ0wi+g48oHN+4gV3pnIY5EG7h04e7G3/7iF83aB0bXbWoFjFRZJDntXU+aVZyKtCT1oeCzGdtsSHEGpgrhZ20hFUgwHwOr/uYAS7k3NiAeTWbHaNCdL2z29XD/URzY7GrYLUiiynu3OjQbj8sulRUqDaO9Vv9/XyaMVwc5WoApcVfdPbHBWb+S49qDG7R8HEzkEIjsXj5sErjMcTTeKCT7+ig340fPxoWX8uaKEl5EdDv0b1V3OTnSEvDi4oHBqkk41mJ5xjvdlp4PQIluTgHXoSMyUKRM0q+pEqgILkkrTUGHtdaioyHwU+/WEVX3pveHm7+mF4nb7ps7SHRQaaqilPurfus5fYSfBbvJfIV0Ey2InclTOGpHVSqVplBpPFPfHmEL1EUpTshnOpmPWNvYeuMoEKsa3ZoKJi3iaLOQxCgi/2rDjKG3gr/++vb/K0NWEpeo7lVgv6vHXixBw0Wwjo0+4Ex8r+0Uw/2jfqsvG4p955xGWh7AXvkqPkBnw9YH6sGAAA=")
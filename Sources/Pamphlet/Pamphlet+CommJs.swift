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
                let responseJson = JSON.parse(this.responseText);
                if (responseJson != undefined) {
                    callback(responseJson);
                }
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

function sendCommand(commandName, commandJson, callback) {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4) {
            if (this.status == 200) {
                if (callback != undefined) {
                    let responseJson = JSON.parse(this.responseText);
                    if (responseJson != undefined) {
                        callback(responseJson);
                    }
                }
            }
        }
    };
    xhttp.open("POST", "/");
    xhttp.setRequestHeader("Flynn-Tag", commandName);
    xhttp.setRequestHeader("Pragma", "no-cache");
    xhttp.setRequestHeader("Expires", "-1");
    xhttp.setRequestHeader("Cache-Control", "no-cache");
    xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhttp.send(JSON.stringify(commandJson));
}

function registerPlayer(name, teamId, callback) {
    sendCommand("PlayerJoin", {
        playerName:name,
        teamId:teamId
    }, callback)
}

function movePlayer(nodeIdx, callback) {
    sendCommand("MovePlayer", {
        nodeIdx:nodeIdx
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

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA+VUTY+bMBC951e4nIgUkmzVQ5UVl0bd7kb7ETWs1KsLE3AXbGqbTaKK/75jPrJAaOlue6nqAwj7vTeD581sM+5rJjgJaQL3aUA1XAserkUc2z6N46/UfxiTHwTXyDweqST7SOuUuITDjny5ub7Er8/wPQOl7fF5gSoQU8El0OCgNIr6EeUhIGlbBbRRtcCaxbbE1hFT04KwMQTiuuRdE9PCGc1MGczb+byLMisGTSSoVHAFK4X/55LV5u52mlKpoI5VHnuw11Xe3VgthTcuyXgAW8Yh6AtpVn1lLWaPeH6yo0B7LAGRabt5Rb+uSz4hZx31nECsoCe9VweY4w13YrS+Ru3tvGWBFLhtre82njUh1sxq+QMzqnxziWUHaVsX8YFzx6OhQX8C/UFQGQyR1pKGCTUMLhyf+hEMMT7uU4YFMhTnbAi8NIrOUnAtRfySKIYCXDveIQXDo2kaM5+ai599Q1ucY0+gGbV7710472u1Ue1eXyQJ5QEa97mWuwVBFXQu+lCCnO5YoCMyIw/FRXli40sAPjniow4+AhZG+oRwWjeFDLtoGKUl4yHbHuwqoTEmmo9GtYeIgS7Loxpyi5aa1D9gOmBCGrPkn5ojBlnn/lsT4M8Hz6uHz0sGUP8Qyn/S5n+3sxsu+a9ae7C1ilp12ktCyJQGuY7pAUPzorU00OQqOO2qZi9aJWMlGMcUnx2TFtvm8heF2PGgFF2Ur7LgjQitpBLxCHVCIoCrYD+Qy82R0MqlIi+qd0/QJ6QDpN+gCAAA")
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
                setTimeout(function() { gameUpdateLongPoll(callback) }, 1);
                let responseJson = JSON.parse(this.responseText);
                if (responseJson != undefined) {
                    callback(responseJson);
                }
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

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA+VUTY/aMBC98yumOQWJAFv1ULHKpajbXbQfqGSlXt1kSNxN7NQ2u6CK/95xPtgYUOn241DVByLs92aex29muRKx4VJAygq8LxNm8FqKdC7z3I9Znn9m8UMfvgGtnv15ZArWmTElhCDwCT7dXF/Sv4/4dYXa+P3zClUhhlIoZMlGGwoaZ0ykSKRlk9CnqBXWLr4E32RcDyvCwhIgDOFNF+PgbMyVtpjX4/E+yi6NJuIFypXxuxl/fM3tAM6aG3RXjgYU6lIKjTNNtQphtri7HZZMaWx118cRrs2RCFa3E+FVCCuR4JILTI7Jt6vV5TCPBN86O1vAXOOfrMiYKuxmdTP23O2tY4EShe/N7xaRNwBv5Dn+IEWNby7p2VH53kW+ESKIWGrRH9C8k0wlp0hzxdKCWYaQQcziDE8x3q9LTkW1lODsFHhqIwZTKYyS+UuyWAoKE0SbEi2PlWXOY2YLP/pCT3lOPUEGMuF9dBG8baP1WsfFsiiYSMhsz2/5NAGKQm4j7yhUwyeemAxG8FAVKpKLWCGKwQ6f7eEz5GlmDgiH76aJ4Vcm10ZxkfLlxm8E9UnottdrPQQWOq2PWsgtWWrQXsC6dgCdWfJPzRGLbLX/VNf+/rD45YHxkqFx2MZHRslf6uyOS/6r1j7ZWtVb7bWXwpRrg2qesw2lFlVrGWTFVXLYVd1e9GrGTHJBEp8dU1bbtviTKtjuoA46qT/1g3cyOKIK+YitIJngVbI+oeVmR3C0NORJ8z2S9DvmxLBooAgAAA==")
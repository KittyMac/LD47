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

function registerPlayer(name, callback) {
    sendCommand("PlayerJoin", {
        playerName:name
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

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA+VUTW+bQBC9+1dMOWHJ2E7VQ+WIS62mqZUPqyZSr1sYwzawS3fXsVHFf+8shgSwWzdpL1X3YIvlvXnDzJtZb0RouBQQswzv8ogZvJIiXso0dUOWpl9YeD+E70BnYH8emIJdYkwOPgjcwufrq0t6+oTfNqiNOzyvUBViLIVCFhXaUNAwYSJGIq1rQZeiVlh7+Bpck3A9rggrSwDfhzdtTAdnY260xbyeTvsoe1I0oFDnUmhcaPo+Hxar25txzpTGRmv/OsCdqfPua3UivPJhIyJcc4HRMUl7mpJ1mEeClwc3Gk3AM5Qb47ZL9Ou+lCM460UvAVONR9J7scCUKtzT6DwNutdlxwI5CtdZ3q4CZwTOxOn4gzKqfXNJbUflOhdpIYQXsNiiP6B5J5mKTpGWisUZswwhvZCFCZ5ivN/lnBpkKd7ZKfDcRvTmUhgl0+eoWAoK4wVFjpbH8jzlIbOFn3wlW5zTTJAZjX8XXHhvm2iDxr2hzDImIjLuUy+3M6Ao5FzyoUI13vLIJDCB+6pQgVyFClGMHvFJD58gjxNzQDjsmyaGWw2MNoqLmK8Lt05oSImWg0HjIbDQ+f5VA7khS42aD7ATMILWLvmn9ohFNrn/1gb488Xz4uXznAV0fAmVPxnzvzvZLZf8V6N9crSqXvXGS2HMtUG1TFlB0mI/Wr1pas+gs0cuJBeU2pNT8uraFn1mg+w72grVUc3kAzaKMsKP0e6E6PUjoSNak2f1/xHRH6/FV1WBCAAA")
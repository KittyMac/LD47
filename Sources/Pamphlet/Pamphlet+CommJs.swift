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

function sendCommand(commandName, commandJson, callback) {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4) {
            if (this.status == 200) {
                callback(JSON.parse(this.responseText));
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

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA+VTW2+bMBR+z6+weCISJOm0hylVXhat66JeooVKe/XgBLyaY892mqCJ/z6bSwu0GtqkvbR+ABm+y/E5n/cHjA0TSFKaw51MqIErgelWcO7HlPPvNL6fkl/Erol7PFBFTpkxkqwIwpF8u766tLuv8PMA2vjT8wpVIWYCFdCk0MaKxhnFFCxp3xj6VrXCusX2xDcZ07OKsHMEslqR911MD+c0D9ph3i0WQ5Rbbe3+Znd7M5NUaWgdtBSoIYKTmTbldpcGE7EcxMH43VL/3J8yIGcDrZIA1/BCZf9ssLAnHXj0dpP+57I3Cgnoe9vbXeQFxJt7vTnZipr5Xdr2g/K9C14ghhFNHfozmI+CqmSMtFU0zaljoAhjGmcwxvh0kszOw1HCszHw2imGa4FGCf43Lo4CaMKokOB4VErOYuoaP/+hBZ7bbNp4mNVddBF+aNWqBwdDYpHnFBMb3adZHpfEqtgsoXUANTuyxGRkTu6rRkViFysADB7x2QCfAUsz84zwfG7aMuoIa6MYpmxf+E1BLrzlZNJmiDjouv7VQm5spIL2ABt71IB07vTrv8/lf7oSnfa+qTsxmkmXsWEuFaRMG1BbTgtrjXUmBzHshterkRvB0Jb2FAVZfXZNXzqReqIdqZ5rLh6gdRQJfElOI6bXj4SeaUNeNu8XTH8DjN3a4EIHAAA=")
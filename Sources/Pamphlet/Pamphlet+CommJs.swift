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
    xhttp.open("GET", "/");
    xhttp.setRequestHeader("Flynn-Tag", "GetBoard");
    xhttp.setRequestHeader("Pragma", "no-cache");
    xhttp.setRequestHeader("Expires", "-1");
    xhttp.setRequestHeader("Cache-Control", "no-cache");
    xhttp.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhttp.send();
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
    xhttp.open("GET", "/");
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
    })
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

private let gzip_data = Data(base64Encoded:"H4sIAAAAAAACA+VUTU/jMBC951dYOTlSU8qKAwL1QsWHEB8VBInrbDpNveuMvbYLjVD+O3baiiSstgKJCzuHRHbem5nMe/Z8SbkTilgBJT7oGTi8UlRMlZQ8Byl/Qv47YS/MRxQeT2DYauGcZmNG+Mwer68u/OoO/yzROp4cN6gGMVRkEGaVdT5pvgAq0JPmm4LcZ22wIcSccbcQdtgQ7gOBjcfsoI3p4ELOpQ2YH6NRHxVi2zu/vL+9GWowFrcVrFZkMcOVSzbttsOiy0SJaul4u9V/z6cesP1erpqhtPiXzj5dYOT/tFejs4q623VHCo3E4/PTLB6weC/uyOQb2sh34aePhsdnsiJKMygC+hzdiQIz20WaGihKCAxSaQ75AncxTldaeDkCJd3fBZ6EjOlEkTNKfqRKoCC5NKs0Bh5oLUUOYe57v6yiY29N7w43fsjO0sN+NpoFT9dRtNWKhb2JKkvwn/L1e8BaR+X7H5P6i5w2lVChuVSC/luvNTJYZwQVYl5t/ZX0LGiwENahWQ+Mk7853luw7dM34XVDufGMo0Bb65dE9SuU2MsfCAYAAA==")
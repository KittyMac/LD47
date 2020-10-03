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
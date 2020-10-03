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
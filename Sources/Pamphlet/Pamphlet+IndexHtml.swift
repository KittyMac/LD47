import Foundation

// swiftlint:disable all

public extension Pamphlet {
    static func IndexHtml() -> String {
#if DEBUG
let filePath = "/Volumes/Development/Development/chimerasw2/LD47/Resources/index.html"
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


<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>LD47 - Escape the Loop</title>
    <link rel="stylesheet" href="style.css">
</head>
<script src="laba.js"></script>
<script src="comm.js"></script>
<script src="pixi.min.js"></script>
<script src="pixi.app.js"></script>
<script src="gl.matrix.min.js"></script>

<body>
    
	<noscript>
		<div style="position:fixed;display:flex;justify-content:center;align-items:center;width:100%;height:100%;padding:0px;margin:0px;overflow:hidden;">
			<h1>The LD47 entry requires Javascript to be enabled.</h1>
		</div>
	</noscript>
    
    <div id="pixi"></div>
    
	<div id="welcomeDialog">
        
        <div class="vstack" style="height:100%;margin-left:30px; margin-right:30px">
            <div class="center" style="height:60px; width:100%">
                <img style="position:absolute;top:-120px" src="logo_black.png" />
            </div>
            <div class="hstack">
                <div class="vstack center" style="width:50%;margin-right:10px;padding-top:10px">
                    <input id="playerName" type="text" placeholder="Player Name" required="true">
                    
                    <div class="hstack center grow" style="width:73%">
                        <img id="team0" style="width:92px;height:92px;opacity:0.3;" src="player0.png" />
                        <img id="team1" style="width:92px;height:92px;opacity:0.3;" src="player1.png" />
                    </div>
                    <div class="hstack center grow" style="width:73%">
                        <img id="team2" style="width:92px;height:92px;opacity:0.3;" src="player2.png" />
                        <img id="team3" style="width:92px;height:92px;opacity:0.3;" src="player3.png" />
                    </div>
                    
                    <button id="playButton" style="height:2em;" >PLAY</button>
                    
                </div>
                <div class="vstack" style="width:50%;margin-left:10px">
                    <div style="text-align: center;"><strong>Enter Name - Select Team - Press Play</strong></div>
                    <p>
                    <strong>Escape the Loop</strong> is multiplayer, online and persistent. Grab some friends and drop in for a hide-and-seek brawl where you work with your team to gain enough points to win the round.
                    <p>
                    Earn points by <strong>landing on other players</strong> or <strong>finding the hidden exit</strong>. First team to <strong>25,000</strong> points wins the round and the game resets. If you need help finding the exit, simply <strong>remain still for 5 seconds</strong> and the number of connections between you and the exit will be displayed.
                    <p>
                    <strong>500 Points</strong> - Escaping through the hidden exit<br>
                    <strong>5 Points</strong> - Land on another player
                                        
                </div>
            </div>
            <div class="center" style="height:30px; width:100%; margin-top:20px">
                Made by <a href="https://github.com/KittyMac/">Rocco Bowling</a> in less than 48 hours for <a href="https://ldjam.com"> Ludum Dare 47</a>
            </div>
            <div class="center" style="height:30px; width:100%; margin-bottom:10px">
                <a href="https://github.com/KittyMac/flynn">Flynn</a>  -  <a href="https://swift.org">Swift</a> - <a href="https://www.pixijs.com">PixiJS</a> - <a href="https://www.raspberrypi.org">Raspberry Pi</a>
            </div>
        </div>
        
	</div>
    
    <script type="text/javascript">
        
        app = initPixi()
        
        var pixiFinishedLoading = false;
        var selectedTeam = 0
        
        // because i always make this mistake!
        print = console.log
        
        // The conversion from board units to screen units
        var kBoardToScreen = 50;
        var kNodeSize = 10;
        var kPlayerSize = 65;
        
        //const kBoardToScreen = 10
        //const kNodeSize = 4
        //const kPlayerSize = 7
        
        let thisPlayer = undefined;
        
        var lastBoardUpdate = undefined;
        var lastBoardUpdateScreenDim = 0;
        
        var playerCanMove = false;
        
        const gameContainer = new PIXI.Container();
        app.stage.addChild(gameContainer);
        
        const lastWinnerText = new PIXI.Text("", {fontFamily : 'Helvetica', fontSize: 18, fill : 0xFFFFFF, align : 'left'});
        lastWinnerText.anchor.set(0.0, 0.0);
        lastWinnerText.x = 10.0
        lastWinnerText.y = (20.0 * 0.0) + 6.0
        app.stage.addChild(lastWinnerText);
        
        const adminMessageText = new PIXI.Text("", {fontFamily : 'Helvetica', fontSize: 18, fill : 0x888888, align : 'left'});
        adminMessageText.anchor.set(0.0, 0.0);
        adminMessageText.x = 10.0
        adminMessageText.y = (20.0 * 1.0) + 6.0
        app.stage.addChild(adminMessageText);
        
        const score0Text = new PIXI.Text("SCORE: ", {fontFamily : 'Helvetica', fontSize: 18, fill : 0x2ca51f, align : 'left'});
        score0Text.anchor.set(0.0, 0.0);
        score0Text.x = 10.0
        score0Text.y = (20.0 * 3.0) + 6.0
        app.stage.addChild(score0Text);
        
        const score1Text = new PIXI.Text("SCORE: ", {fontFamily : 'Helvetica', fontSize: 18, fill : 0xc0432e, align : 'left'});
        score1Text.anchor.set(0.0, 0.0);
        score1Text.x = 10.0
        score1Text.y = (20.0 * 4.0) + 6.0
        app.stage.addChild(score1Text);
        
        const score2Text = new PIXI.Text("SCORE: ", {fontFamily : 'Helvetica', fontSize: 18, fill : 0x1f71a5, align : 'left'});
        score2Text.anchor.set(0.0, 0.0);
        score2Text.x = 10.0
        score2Text.y = (20.0 * 5.0) + 6.0
        app.stage.addChild(score2Text);
        
        const score3Text = new PIXI.Text("SCORE: ", {fontFamily : 'Helvetica', fontSize: 18, fill : 0xecd034, align : 'left'});
        score3Text.anchor.set(0.0, 0.0);
        score3Text.x = 10.0
        score3Text.y = (20.0 * 6.0) + 6.0
        app.stage.addChild(score3Text);
        
        
        
        const boardGfx = new PIXI.Graphics();
        gameContainer.addChild(boardGfx);
        
        const nodeText = new PIXI.Text('0000', {fontFamily : 'Helvetica', fontSize: 18, fill : 0xffffff, align : 'center'});
        nodeText.anchor.set(0.5, 0.5);
        gameContainer.addChild(nodeText);
        
        const playersContainer = new PIXI.Container();
        gameContainer.addChild(playersContainer);
                
        function animationUpdate() {
            // 0. Did the screen change size since the last time we drew the board? if so, we
            // should redraw it so that it stays centered
            let cx = app.renderer.width / 2
            let cy = app.renderer.height / 2
            let dim = Math.floor(app.renderer.width) * Math.floor(app.renderer.height);
            
            var animationDelta = 0.06135;
            
            if (lastBoardUpdateScreenDim != dim) {
                animationDelta = 1.0;
                
                // we want to display X number of board tiles regardless of the size of the screen...
                kBoardToScreen = Math.max(app.renderer.width, app.renderer.height) / 36;
                                
                updateBoard(lastBoardUpdate);
            }
            
            // 1. rotate all players
            var hasPlayer = false;
            for (j in playersContainer.children) {
                let playerContainer = playersContainer.children[j];
                
                playerContainer.x += (playerContainer.targetX - playerContainer.x) * animationDelta;
                playerContainer.y += (playerContainer.targetY - playerContainer.y) * animationDelta;
                
                let dx = Math.abs(playerContainer.targetX - playerContainer.x);
                let dy = Math.abs(playerContainer.targetY - playerContainer.y);
                
                var distanceToMove = (dx + dy) * 0.5;
                
                var playerGfx = playerContainer.children[0];
                
                if (playerContainer.targetX < playerContainer.x) {
                    playerGfx.rotation -= 0.01 * (1.0 + distanceToMove * 0.1);
                } else {
                    playerGfx.rotation += 0.01 * (1.0 + distanceToMove * 0.1);
                }
                
                if (playerContainer.isPlayer) {
                    hasPlayer = true;
                    
                    gameContainer.x = -(playerContainer.x - app.renderer.width / 2)
                    gameContainer.y = -(playerContainer.y - app.renderer.height / 2)
                    
                    if (dx < kPlayerSize && dy < kPlayerSize) {
                        playerCanMove = true;
                    } else {
                        playerCanMove = false;
                    }
                }
            }
            
            
            if (hasPlayer == false) {
                let node = {x:6000, y:6000}
                let pos = getNodePos(node);
                gameContainer.x = -(pos[0] - app.renderer.width / 2)
                gameContainer.y = -(pos[1] - app.renderer.height / 2)
            }
        }
        
        
        function getNodeByIdx(nodes, idx) {
            // we've can't just use nextIdx to index the array because we are not
            // given ALL of the nodes
            for (i in nodes) {
                let node = nodes[i]
                if (node.id == idx) {
                    return node;
                }
            }
            return undefined;
        }
        
        function getNextNode(nodes, current, idx) {
            let nextIdx = current.c[idx];
            if (nextIdx != undefined) {
                return getNodeByIdx(nodes, nextIdx);
            }
            return undefined;
        }
        
        function getNodePos(node) {
            return [node.x * kBoardToScreen, node.y * kBoardToScreen]
        }
        
        function updateBoard(board) {
            let dim = Math.floor(app.renderer.width) * Math.floor(app.renderer.height);
            lastBoardUpdateScreenDim = dim
            
            if (board == undefined) {
                return;
            }
            
            lastBoardUpdate = board;
            
            // -1. we want to center the board around the player's nodeidx
            let nodes = board.nodes;
            let players = board.players;
            
            boardGfx.clear()
            
            // 0. draw all of the lines connecting the nodes
            boardGfx.lineStyle(5, 0x373737, 1);
            for (i in nodes) {
                let node = nodes[i];
                let posA = getNodePos(node);
                
                for (j in node.c) {
                    let nextNode = getNextNode(nodes, node, j);
                    if (nextNode != undefined) {
                        let posB = getNodePos(nextNode);
                        boardGfx.moveTo(posA[0], posA[1]);
                        boardGfx.lineTo(posB[0], posB[1]);
                    }
                }
            }
            
            // 1. draw all of the nodes
            boardGfx.lineStyle(0);
            for (i in nodes) {
                let node = nodes[i];
                boardGfx.beginFill(0xbdbdbd, 1);
                let pos = getNodePos(node);
                boardGfx.drawCircle(pos[0], pos[1], kNodeSize);
                boardGfx.endFill();
            }
            
            if (thisPlayer != undefined && board.player == undefined) {
                // we were destroyed since the last update
                openWelcomeDialog()
            }
            
            thisPlayer = board.player;
            
            // 3. special stuff for THE player
            if (thisPlayer != undefined) {
                let playerNode = getNodeByIdx(nodes, thisPlayer.nodeIdx);
                let pos = getNodePos(playerNode);
                nodeText.x = pos[0];
                nodeText.y = pos[1] + kPlayerSize * 0.75;
                
                nodeText.text = thisPlayer.hint;
            }
            
            // flag player containers so we can remove the ones which are no longer visible
            for (j in playersContainer.children) {
                let playerContainer = playersContainer.children[j];
                playerContainer.shouldBeRemoved = true;
            }
            
            // 2. add the players
            for (i in players) {
                let player = players[i];
                let node = getNodeByIdx(nodes, player.nodeIdx);
                if (node != undefined) {
                    // does a graphics already exist for this one?
                    var playerContainer = undefined;
                    for (j in playersContainer.children) {
                        let otherPlayerContainer = playersContainer.children[j];
                        if (otherPlayerContainer.playerID == player.id) {
                            playerContainer = otherPlayerContainer;
                            break;
                        }
                    }
                
                    if (playerContainer == undefined) {
                        playerContainer = new PIXI.Container();
                        playersContainer.addChild(playerContainer);
                        
                        playerGfx = makeSprite(app, "player" + player.teamId);
                        playerGfx.width = kPlayerSize;
                        playerGfx.height = kPlayerSize;
                        playerContainer.addChild(playerGfx);
                        
                        const nodeText = new PIXI.Text(player.name, {fontFamily : 'Helvetica', fontSize: 18, fill : 0xffffff, align : 'center'});
                        nodeText.anchor.set(0.5, 0.5);
                        nodeText.y = kPlayerSize * -0.75;
                        playerContainer.addChild(nodeText);
                        
                        playerContainer.playerID = player.id;
                                            
                        let pos = getNodePos(node);
                        playerContainer.x = pos[0];
                        playerContainer.y = pos[1];
                    }
                
                    let pos = getNodePos(node);
                    playerContainer.targetX = pos[0];
                    playerContainer.targetY = pos[1];
                    
                    playerContainer.isPlayer = (thisPlayer != undefined && thisPlayer.id == player.id);
                    
                    if (player.immune) {
                        playerContainer.alpha = 0.6
                    } else {
                        playerContainer.alpha = 1.0
                    }
                    
                    playerContainer.shouldBeRemoved = false;
                }
            }
            
            // remove old player containers
            for (j in playersContainer.children) {
                let playerContainer = playersContainer.children[j];
                if (playerContainer.shouldBeRemoved) {
                    playerContainer.parent.removeChild(playerContainer);
                }
            }
            
            // Display the welcome dialog
            if (thisPlayer != undefined) {
                closeWelcomeDialog();
            }
            
            adminMessageText.text = board.adminMessage;
            lastWinnerText.text = board.lastWinner;
            score0Text.text = "SCORE: " + board.scores[0];
            score1Text.text = "SCORE: " + board.scores[1];
            score2Text.text = "SCORE: " + board.scores[2];
            score3Text.text = "SCORE: " + board.scores[3];
            
            // handle any events which were sent along with this update
            let eventPlayerKills = board.eventPlayerKills;
            for (i in eventPlayerKills) {
                let event = eventPlayerKills[i];
                print(event);
            }
        }
        
        welcomeDialog.closed = true;
        
		team0.addEventListener('click', function() {
            selectedTeam = 0;
            updateWindowDialog();
		})
        
		team1.addEventListener('click', function() {
            selectedTeam = 1;
            updateWindowDialog();
		})
        
		team2.addEventListener('click', function() {
            selectedTeam = 2;
            updateWindowDialog();
		})
        
		team3.addEventListener('click', function() {
            selectedTeam = 3;
            updateWindowDialog();
		})
        
        function updateWindowDialog() {
            var team0Opacity = (selectedTeam == 0) ? 1.0 : 0.2;
            var team1Opacity = (selectedTeam == 1) ? 1.0 : 0.2;
            var team2Opacity = (selectedTeam == 2) ? 1.0 : 0.2;
            var team3Opacity = (selectedTeam == 3) ? 1.0 : 0.2;
            
            Laba.animate(team0, "d0.27f" + team0Opacity)
            Laba.animate(team1, "d0.27f" + team1Opacity)
            Laba.animate(team2, "d0.27f" + team2Opacity)
            Laba.animate(team3, "d0.27f" + team3Opacity)
        }
        
        function openWelcomeDialog() {
            if (welcomeDialog.closed == true) {
                welcomeDialog.closed = false;
                welcomeDialog.style["pointer-events"] = "auto";
                Laba.animate(welcomeDialog, "!f1");
                
                updateWindowDialog();
            }
        }
        
        function closeWelcomeDialog() {
            if (welcomeDialog.closed == false) {
                welcomeDialog.closed = true;
                Laba.animate(welcomeDialog, "!f0", undefined, function() {
                    welcomeDialog.style["pointer-events"] = "none";
                });
            }
        }
        
		playButton.addEventListener('click', function() {
            registerPlayer(playerName.value, selectedTeam, function (info) {
                if (info.tag == "PlayerInfo") {
                    closeWelcomeDialog();
                }
            })
		})
        
		playerName.addEventListener("keyup", function(event) {
			if (event.keyCode === 13) {
				event.preventDefault();
                playButton.click();
			}
		});
                
        
        function onPointerDown(event) {
            if (playerCanMove == false) {
                return;
            }
            if (thisPlayer == undefined) {
                return;
            }
            
            let mousePos = event.data.getLocalPosition(gameContainer)
            
            // find the node nearest the click
            var clickNode = undefined
            var clickNodeDistance = 999999999
            let nodes = lastBoardUpdate.nodes;
            let playerNode = getNodeByIdx(nodes, thisPlayer.nodeIdx);
            
            for (i in nodes) {
                let node = nodes[i];
                
                // disclude the player's node, only include nodes which are adjacent to player node
                if (node.id != thisPlayer.nodeIdx && playerNode.c.includes(node.id)) {
                    let pos = getNodePos(node);
                    let dx = (mousePos.x - pos[0])
                    let dy = (mousePos.y - pos[1])
                    let d = dx * dx + dy * dy;
                
                    if (clickNode == undefined || d < clickNodeDistance) {
                        clickNode = node;
                        clickNodeDistance = d;
                    }
                }
            }
            
            if (clickNode != undefined) {
                movePlayer(clickNode.id, function (info) {
                    if (info.tag == "BoardUpdate") {
                        updateBoard(info)
                    }
                })
            }
        }
        app.renderer.plugins.interaction.on('pointerdown', onPointerDown);
        
        
        app.loader
        .add("player0", "player0.png")
        .add("player1", "player1.png")
        .add("player2", "player2.png")
        .add("player3", "player3.png")
        .load((loader, resources) => {
            pixiFinishedLoading = true;
            
            openWelcomeDialog();
            
            gameUpdateLongPoll(function (info) {
                if (info.tag == "BoardUpdate") {
                    updateBoard(info)
                }
                if (info.tag == "PlayerInfo") {
                    print(info)
                }
            })
            
            animationUpdate()
            app.ticker.add(() => {
                while(consistentFrameRate(app, 16)) {
                    animationUpdate()
                }
            });
            
        });
                
    </script>
    
</body>
</html>

"""###
#endif
}
}


public extension Pamphlet {
    static func IndexHtmlGzip() -> Data {
        return gzip_data!
    }
}

private let gzip_data = Data(base64Encoded:"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")
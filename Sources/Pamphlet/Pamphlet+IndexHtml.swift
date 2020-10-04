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
                    Earn points by <strong>landing on other players</strong> or <strong>finding the hidden exit</strong>. First team to <strong>10,000</strong> points wins the round and the game resets. If you need help finding the exit, simply <strong>remain still for 5 seconds</strong> and the number of connections between you and the exit will be displayed.
                    <p>
                    <strong>150 Points</strong> - Escaping through the hidden exit<br>
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
            
            let mousePos = event.data.getLocalPosition(gameContainer)
            
            // find the node nearest the click
            var clickNode = undefined
            var clickNodeDistance = (kPlayerSize * 6) * (kPlayerSize * 6)
            let nodes = lastBoardUpdate.nodes;
            for (i in nodes) {
                let node = nodes[i];
                let pos = getNodePos(node);
                let dx = (mousePos.x - pos[0])
                let dy = (mousePos.y - pos[1])
                let d = dx * dx + dy * dy;
                
                if (d < clickNodeDistance) {
                    clickNode = node;
                    clickNodeDistance = d;
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
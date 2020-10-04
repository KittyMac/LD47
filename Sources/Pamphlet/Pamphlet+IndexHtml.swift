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
                <h3>Escape the Loop</h3>
            </div>
            <div class="hstack">
                <div class="vstack center" style="width:50%;margin-right:10px">
                    <input id="playerName" type="text" placeholder="Player Name" required="true">
                    
                    <div class="hstack center grow" style="width:73%">
                        <img id="team0" style="width:92px;height:92px;opacity:0.3;" src="player0.png" />
                        <img id="team1" style="width:92px;height:92px;opacity:0.3;" src="player1.png" />
                        <img id="team2" style="width:92px;height:92px;opacity:0.3;" src="player2.png" />
                        <img id="team3" style="width:92px;height:92px;opacity:0.3;" src="player3.png" />
                    </div>
                    
                    <button id="playButton" >PLAY</button>
                    
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
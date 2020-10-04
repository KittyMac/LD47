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
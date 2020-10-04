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
                    <h3 style="text-align: center;">Enter Name - Select Team - Press Play</h3>
                    
                    <p>
                    Work with your team to garner enough points to win the round. Earn points by <strong>landing on other players</strong> or <strong>finding the hidden exit</strong>.
                    <p>
                    First team to <strong>10,000</strong> points wins the round and the game resets. If you need help finding the exit, simply
                    <strong>remain still for 5 seconds</strong> and the number of connections between you and the exit will be displayed.

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
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
            <div class="center" style="height:30px; width:100%; margin-top:20px; margin-bottom:10px">
                Made by Rocco Bowling in less than 48 hours for <a href="https://ldjam.com"> Ludum Dare 47</a>
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
        
        
        const score0Text = new PIXI.Text("SCORE: ", {fontFamily : 'Helvetica', fontSize: 18, fill : 0x2ca51f, align : 'left'});
        score0Text.anchor.set(0.0, 0.0);
        score0Text.x = 10.0
        score0Text.y = 6.0
        app.stage.addChild(score0Text);
        
        const score1Text = new PIXI.Text("SCORE: ", {fontFamily : 'Helvetica', fontSize: 18, fill : 0xc0432e, align : 'left'});
        score1Text.anchor.set(0.0, 0.0);
        score1Text.x = 10.0
        score1Text.y = 26.0
        app.stage.addChild(score1Text);
        
        const score2Text = new PIXI.Text("SCORE: ", {fontFamily : 'Helvetica', fontSize: 18, fill : 0x1f71a5, align : 'left'});
        score2Text.anchor.set(0.0, 0.0);
        score2Text.x = 10.0
        score2Text.y = 46.0
        app.stage.addChild(score2Text);
        
        const score3Text = new PIXI.Text("SCORE: ", {fontFamily : 'Helvetica', fontSize: 18, fill : 0xecd034, align : 'left'});
        score3Text.anchor.set(0.0, 0.0);
        score3Text.x = 10.0
        score3Text.y = 66.0
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
            
            score0Text.text = "SCORE: " + board.scores[0]
            score1Text.text = "SCORE: " + board.scores[1]
            score2Text.text = "SCORE: " + board.scores[2]
            score3Text.text = "SCORE: " + board.scores[3]
            
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
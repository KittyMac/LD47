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
    <title>LD47</title>
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
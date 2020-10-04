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
                    
                    Work with your team to garner enough points to win the round. Earn points by landing on other players or finding the hidden exit.
                    <p>
                    First team to <strong>10,000</strong> points wins the round and the game resets. If you need help finding the exit, simply
                    remains still for 5 seconds and the number of connections between you and the exit will be displayed.

                    <ul>
                        <li><strong>150 Points</strong> - Escaping through the hidden exit
                        <li><strong>5 Points</strong> - Land on another player
                    </ul>
                                        
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
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
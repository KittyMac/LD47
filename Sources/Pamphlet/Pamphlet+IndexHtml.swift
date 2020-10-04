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
        
        <div class="vstack">
            <div class="center" style="height:60px; width:100%">
                <h3>QuantumLoop</h3>
            </div>
            <div class="hstack">
                <div class="vstack center" style="width:50%">
                    <input id="playerName" type="text" placeholder="Player Name" required="true">
                    
                    <div class="hstack center grow" style="width:73%">
                        <img id="team0" style="width:92px;height:92px;opacity:0.3;" src="player0.png" />
                        <img id="team1" style="width:92px;height:92px;opacity:0.3;" src="player1.png" />
                        <img id="team2" style="width:92px;height:92px;opacity:0.3;" src="player2.png" />
                        <img id="team3" style="width:92px;height:92px;opacity:0.3;" src="player3.png" />
                    </div>
                    
                    <button id="playButton" >PLAY</button>
                    
                </div>
                <div class="vstack" style="width:50%">
                    <ul>
                        <li><strong>Enter Name</strong>
                        <li><strong>Select Team</strong>
                        <li><strong>Press Play</strong>
                    </ul>
                                            
                    <ul>
                        <li>5 pts for landing on another player
                        <li>150 pts for escaping the loop
                    </ul>
                    <ul>
                        <li>Game resets when a team scores 100,000 points
                        <li>Remain still for 10 seconds to scan for information of where the exit is
                    </ul>
                                        
                </div>
            </div>
            <div class="center" style="height:30px; width:100%; margin-top:20px">
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
                let node = {x:10000, y:10000}
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
                nodeText.text = playerNode.d;
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
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
                <h3>Escape the Loop</h3>
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
                    <strong style="text-align: center;">Enter Name • Select Team • Press Play</strong>
                    
                    <p>
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
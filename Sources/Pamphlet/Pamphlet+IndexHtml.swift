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
                    <strong>Enter Name • Select Team • Press Play</strong>
                    
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
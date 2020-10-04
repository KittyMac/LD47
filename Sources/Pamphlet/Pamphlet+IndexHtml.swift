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
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
        const kBoardToScreen = 50
        const kNodeSize = 20
        const kPlayerSize = 35
        
        //const kBoardToScreen = 10
        //const kNodeSize = 4
        //const kPlayerSize = 7
        
        var lastBoardUpdate = undefined;
        var lastBoardUpdateCX = 0;
        var lastBoardUpdateCY = 0;
        
        var playerCanMove = false;
        
        const gameContainer = new PIXI.Container();
        app.stage.addChild(gameContainer);
        
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
            
            if (lastBoardUpdateCX != cx || lastBoardUpdateCY != cy) {
                updateBoard(lastBoardUpdate);
            }
            
            // 1. rotate all players
            var hasPlayer = false;
            for (j in playersContainer.children) {
                let playerContainer = playersContainer.children[j];
                
                playerContainer.x += (playerContainer.targetX - playerContainer.x) * 0.06135;
                playerContainer.y += (playerContainer.targetY - playerContainer.y) * 0.06135;
                
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
                    
                    if (dx < kNodeSize && dy < kNodeSize) {
                        playerCanMove = true;
                    } else {
                        playerCanMove = false;
                    }
                }
            }
            
            if (hasPlayer == false) {
                // first find any player and center on them
                if (playersContainer.children.length > 0) {
                    let playerContainer = playersContainer.children[0];
                    gameContainer.x = -(playerContainer.x - app.renderer.width / 2)
                    gameContainer.y = -(playerContainer.y - app.renderer.height / 2)
                } else {
                    let node = {x:10000, y:10000}
                    let pos = getNodePos(node);
                    gameContainer.x = -(pos[0] - app.renderer.width / 2)
                    gameContainer.y = -(pos[1] - app.renderer.height / 2)
                }
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
            if (board == undefined) {
                return;
            }
            
            lastBoardUpdate = board;
            lastBoardUpdateCX = app.renderer.width;
            lastBoardUpdateCY = app.renderer.height;
            
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
            
            let thisPlayer = board.player;
            
            // 3. special stuff for THE player
            if (thisPlayer != undefined) {
                let playerNode = getNodeByIdx(nodes, thisPlayer.nodeIdx);
                let pos = getNodePos(playerNode);
                nodeText.x = pos[0];
                nodeText.y = pos[1] + kNodeSize * 2.5;
                nodeText.text = playerNode.d;
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
                        playerContainer.addChild(playerGfx);
                        
                        const nodeText = new PIXI.Text(player.name, {fontFamily : 'Helvetica', fontSize: 18, fill : 0xffffff, align : 'center'});
                        nodeText.anchor.set(0.5, 0.5);
                        nodeText.y = kNodeSize * -2.0;
                        playerContainer.addChild(nodeText);
                        
                        playerContainer.playerID = player.id;
                                            
                        let pos = getNodePos(node);
                        playerContainer.x = pos[0];
                        playerContainer.y = pos[1];
                    }
                
                    let pos = getNodePos(node);
                    playerContainer.targetX = pos[0];
                    playerContainer.targetY = pos[1];
                    
                    playerContainer.isPlayer = (thisPlayer.id == player.id);
                }
            }
            
            // Display the welcome dialog
            if (thisPlayer != undefined) {
                closeWelcomeDialog();
            }
        }
        
        welcomeDialog.closed = true;
        
		team0.addEventListener('click', function() {
            selectedTeam = 0;
		})
        
		team1.addEventListener('click', function() {
            selectedTeam = 1;
		})
        
		team2.addEventListener('click', function() {
            selectedTeam = 2;
		})
        
		team3.addEventListener('click', function() {
            selectedTeam = 3;
		})
        
        function updateWindowDialog() {
            var team0Opacity = (selectedTeam == 0) ? 1.0 : 0.2;
            var team1Opacity = (selectedTeam == 1) ? 1.0 : 0.2;
            var team2Opacity = (selectedTeam == 2) ? 1.0 : 0.2;
            var team3Opacity = (selectedTeam == 3) ? 1.0 : 0.2;
            
            Laba.animate(team0, "f" + team0Opacity)
            Laba.animate(team1, "f" + team1Opacity)
            Laba.animate(team2, "f" + team2Opacity)
            Laba.animate(team3, "f" + team3Opacity)
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
            registerPlayer(playerName.value, 1, function (info) {
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
            var clickNodeDistance = (kNodeSize * 6) * (kNodeSize * 6)
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
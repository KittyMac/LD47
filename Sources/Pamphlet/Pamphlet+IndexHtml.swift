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
        var kNodeSize = 20;
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
                nodeText.y = pos[1] + kNodeSize * 2.5;
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
                    
                    playerContainer.isPlayer = (thisPlayer != undefined && thisPlayer.id == player.id);
                    
                    playerContainer.shouldBeRemoved = false;
                }
            }
            
            // remove old player containers
            for (j in playersContainer.children) {
                let playerContainer = playersContainer.children[j];
                if (playerContainer.shouldBeRemoved) {
                    print("removing player container");
                    playerContainer.parent.removeChild(playerContainer);
                }
            }
            
            // Display the welcome dialog
            if (thisPlayer != undefined) {
                closeWelcomeDialog();
            }
            
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
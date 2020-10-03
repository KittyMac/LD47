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
                        <div style="width:92px;height:92px;background-color:#FF0000"></div>
                        <div style="width:92px;height:92px;background-color:#00FF00"></div>
                        <div style="width:92px;height:92px;background-color:#0000FF"></div>
                        <div style="width:92px;height:92px;background-color:#FFFF00"></div>
                    </div>
                    
                    <button id="playButton">PLAY</button>
                    
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
        </div>
        
	</div>
    
    <script type="text/javascript">
        
        app = initPixi()
        
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
                playerGfx.rotation += 0.01 * (1.0 + distanceToMove * 0.1);
                
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
                        
                        playerGfx = new PIXI.Graphics();
                        playerContainer.addChild(playerGfx);
                        
                        const nodeText = new PIXI.Text(player.name, {fontFamily : 'Helvetica', fontSize: 18, fill : 0xffffff, align : 'center'});
                        nodeText.anchor.set(0.5, 0.5);
                        nodeText.y = kNodeSize * -2.0;
                        playerContainer.addChild(nodeText);
                        
                        playerContainer.playerID = player.id;
                    
                        playerGfx.beginFill(0xff0000, 1);
                        playerGfx.drawStar(0, 0, 4, kPlayerSize);
                        playerGfx.endFill();
                        
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
        
        gameUpdateLongPoll(function (info) {
            if (info.tag == "BoardUpdate") {
                updateBoard(info)
            }
            if (info.tag == "PlayerInfo") {
                print(info)
            }
        })
        
        welcomeDialog.closed = true;
        function openWelcomeDialog() {
            if (welcomeDialog.closed == true) {
                welcomeDialog.closed = false;
                welcomeDialog.style["pointer-events"] = "auto";
                Laba.animate(welcomeDialog, "!f1");
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
        
        openWelcomeDialog();
        
		playButton.addEventListener('click', function() {
            registerPlayer(playerName.value, function (info) {
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
        //.add("space", "outLogin/space.jpg")
        //.add("lines", "outLogin/lines.jpg")
        .load((loader, resources) => {
            //spaceSprite = makeSprite(app, "space");
            //linesSprite = makeTilingSprite(app, "lines", 2731, 1024);
            
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
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
    <title>LD47 - Escape the Loop</title>
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
                <img style="position:absolute;top:-120px" src="logo_black.png" />
            </div>
            <div class="hstack">
                <div class="vstack center" style="width:50%;margin-right:10px;padding-top:10px">
                    <input id="playerName" type="text" placeholder="Player Name" required="true">
                    
                    <div class="hstack center grow" style="width:73%">
                        <img id="team0" style="width:92px;height:92px;opacity:0.3;" src="player0.png" />
                        <img id="team1" style="width:92px;height:92px;opacity:0.3;" src="player1.png" />
                    </div>
                    <div class="hstack center grow" style="width:73%">
                        <img id="team2" style="width:92px;height:92px;opacity:0.3;" src="player2.png" />
                        <img id="team3" style="width:92px;height:92px;opacity:0.3;" src="player3.png" />
                    </div>
                    
                    <button id="playButton" style="height:2em;" >PLAY</button>
                    
                </div>
                <div class="vstack" style="width:50%;margin-left:10px">
                    <div style="text-align: center;"><strong>Enter Name - Select Team - Press Play</strong></div>
                    <p>
                    <strong>Escape the Loop</strong> is multiplayer, online and persistent. Grab some friends and drop in for a hide-and-seek brawl where you work with your team to gain enough points to win the round.
                    <p>
                    Earn points by <strong>landing on other players</strong> or <strong>finding the hidden exit</strong>. First team to <strong>25,000</strong> points wins the round and the game resets. If you need help finding the exit, simply <strong>remain still for 5 seconds</strong> and the number of connections between you and the exit will be displayed.
                    <p>
                    <strong>500 Points</strong> - Escaping through the hidden exit<br>
                    <strong>5 Points</strong> - Land on another player
                                        
                </div>
            </div>
            <div class="center" style="height:30px; width:100%; margin-top:20px">
                Made by <a href="https://github.com/KittyMac/">Rocco Bowling</a> in less than 48 hours for <a href="https://ldjam.com"> Ludum Dare 47</a>
            </div>
            <div class="center" style="height:30px; width:100%; margin-bottom:10px">
                <a href="https://github.com/KittyMac/flynn">Flynn</a>  -  <a href="https://swift.org">Swift</a> - <a href="https://www.pixijs.com">PixiJS</a> - <a href="https://www.raspberrypi.org">Raspberry Pi</a>
            </div>
        </div>
        
	</div>
    
    <script type="text/javascript">
        
        app = initPixi()
        
        var pixiFinishedLoading = false;
        var selectedTeam = 0
        
        let vec2 = glMatrix.vec2
        
        // because i always make this mistake!
        print = console.log
        
        // The conversion from board units to screen units
        var kBoardToScreen = 50;
        var kNodeSize = 10;
        var kPlayerSize = 65;
        
        var lastMousePos = undefined
        
        //const kBoardToScreen = 10
        //const kNodeSize = 4
        //const kPlayerSize = 7
        
        let thisPlayer = undefined;
        
        var lastBoardUpdate = undefined;
        var lastBoardUpdateScreenDim = 0;
        
        var playerCanMove = false;
        
        const gameContainer = new PIXI.Container();
        app.stage.addChild(gameContainer);
        
        const lastWinnerText = new PIXI.Text("", {fontFamily : 'Helvetica', fontSize: 18, fill : 0xFFFFFF, align : 'left'});
        lastWinnerText.anchor.set(0.0, 0.0);
        lastWinnerText.x = 10.0
        lastWinnerText.y = (20.0 * 0.0) + 6.0
        app.stage.addChild(lastWinnerText);
        
        const adminMessageText = new PIXI.Text("", {fontFamily : 'Helvetica', fontSize: 18, fill : 0x888888, align : 'left'});
        adminMessageText.anchor.set(0.0, 0.0);
        adminMessageText.x = 10.0
        adminMessageText.y = (20.0 * 1.0) + 6.0
        app.stage.addChild(adminMessageText);
        
        const score0Text = new PIXI.Text("SCORE: ", {fontFamily : 'Helvetica', fontSize: 18, fill : 0x2ca51f, align : 'left'});
        score0Text.anchor.set(0.0, 0.0);
        score0Text.x = 10.0
        score0Text.y = (20.0 * 3.0) + 6.0
        app.stage.addChild(score0Text);
        
        const score1Text = new PIXI.Text("SCORE: ", {fontFamily : 'Helvetica', fontSize: 18, fill : 0xc0432e, align : 'left'});
        score1Text.anchor.set(0.0, 0.0);
        score1Text.x = 10.0
        score1Text.y = (20.0 * 4.0) + 6.0
        app.stage.addChild(score1Text);
        
        const score2Text = new PIXI.Text("SCORE: ", {fontFamily : 'Helvetica', fontSize: 18, fill : 0x1f71a5, align : 'left'});
        score2Text.anchor.set(0.0, 0.0);
        score2Text.x = 10.0
        score2Text.y = (20.0 * 5.0) + 6.0
        app.stage.addChild(score2Text);
        
        const score3Text = new PIXI.Text("SCORE: ", {fontFamily : 'Helvetica', fontSize: 18, fill : 0xecd034, align : 'left'});
        score3Text.anchor.set(0.0, 0.0);
        score3Text.x = 10.0
        score3Text.y = (20.0 * 6.0) + 6.0
        app.stage.addChild(score3Text);
        
        
        
        const boardGfx = new PIXI.Graphics();
        gameContainer.addChild(boardGfx);
        
        const nodeText = new PIXI.Text('0000', {fontFamily : 'Helvetica', fontSize: 18, fill : 0xffffff, align : 'center'});
        nodeText.anchor.set(0.5, 0.5);
        gameContainer.addChild(nodeText);
        
        const playersContainer = new PIXI.Container();
        gameContainer.addChild(playersContainer);
        
        
        const particleContainer = new PIXI.ParticleContainer(10000, {
            scale: true,
            position: true,
            rotation: true,
            uvs: true,
            alpha: true,
        });
        gameContainer.addChild(particleContainer);
        
        
        
                
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
                let node = {x:3000, y:3000}
                let pos = getNodePos(node);
                gameContainer.x = -(pos[0] - app.renderer.width / 2)
                gameContainer.y = -(pos[1] - app.renderer.height / 2)
            }
            
            // update all particles
            for (i in particleContainer.children) {
                let particle = particleContainer.children[i]
                particle.currentLife -= 16
                
                if (particle.currentLife <= 0) {
                    particle.parent.removeChild(particle);
                } else {
                    particle.velocity[0] *= particle.friction;
                    particle.velocity[1] *= particle.friction;
                    particle.x += particle.velocity[0];
                    particle.y += particle.velocity[1];
                    particle.rotation += particle.velocity[0] / 6;
                    particle.alpha = particle.currentLife / particle.totalLife;
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
        
        function explode(team, x, y, num) {
            for (i = 0; i < num; i++) {
                let star = makeSprite(app, "star");
                star.width = kPlayerSize * 0.5;
                star.height = kPlayerSize * 0.5;
                star.totalLife = 1200;
                star.currentLife = star.totalLife;
                star.velocity = [Math.random() * 12 - 6, Math.random() * 12 - 6]
                star.friction = 0.95;
                star.x = x + star.velocity[0] * 3.0;
                star.y = y + star.velocity[1] * 3.0;
                if (team == 0) {
                    star.tint = 0x40eb2d;
                } else if (team == 1) {
                    star.tint = 0xef634b;
                } else if (team == 2) {
                    star.tint = 0x309fe6;
                } else if (team == 3) {
                    star.tint = 0xf8ea9b;
                }
                particleContainer.addChild(star);
            }
        }
        
        function updateBoard(board) {
            let dim = Math.floor(app.renderer.width) * Math.floor(app.renderer.height);
            lastBoardUpdateScreenDim = dim
            
            if (board == undefined) {
                return;
            }
            
            let nodes = board.nodes;
            let players = board.players;
            
            // handle any events which were sent along with this update
            let eventPlayerKills = board.eventPlayerKills;
            for (i in eventPlayerKills) {
                let event = eventPlayerKills[i];
                
                let playerKilled = event.player;
                let node = getNodeByIdx(nodes, playerKilled.nodeIdx);
                
                if (node != undefined) {
                    let pos = getNodePos(node);
                    explode(playerKilled.teamId, pos[0], pos[1], 6);
                }
            }
            
            // We need to reject out-of-order board updates.  The count value is 0-65535 and loops.
            if (lastBoardUpdate != undefined) {
                if (board.count >= lastBoardUpdate.count ||
                    lastBoardUpdate.count >= 32767 && board.count < 32767) {
                
                } else {
                    print("skipping out of order board update")
                    return;
                }
            }
            
            lastBoardUpdate = board;
            
            // -1. we want to center the board around the player's nodeidx
            boardGfx.clear()
            
            var playerNode = undefined
            var moveTint = 0x979797;
            if (thisPlayer != undefined) {
                playerNode = getNodeByIdx(nodes, thisPlayer.nodeIdx);
                
                let team = thisPlayer.teamId;
                if (team == 0) {
                    moveTint = 0x1c6613;
                } else if (team == 1) {
                    moveTint = 0x662a20;
                } else if (team == 2) {
                    moveTint = 0x154766;
                } else if (team == 3) {
                    moveTint = 0x66603f;
                }
            }
            
            let highlightNode = calculateMoveToNode(lastMousePos);
            
            // 0. draw all of the lines connecting the nodes
            let highlightNodeID = highlightNode != undefined ? highlightNode.id : -1
            let playerNodeID = playerNode != undefined ? playerNode.id : -1
            
            boardGfx.lineStyle(5, 0x373737, 1);
            for (i in nodes) {
                let node = nodes[i];
                let posA = getNodePos(node);
                
                for (j in node.c) {
                    let nextNode = getNextNode(nodes, node, j);
                    if (nextNode != undefined) {
                        
                        if (nextNode.id == highlightNodeID && node.id == playerNodeID ||
                            nextNode.id == playerNodeID && node.id == highlightNodeID) {
                            boardGfx.lineStyle(5, moveTint, 1);
                        }else{
                            boardGfx.lineStyle(5, 0x373737, 1);
                        }
                        
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
                playerNode = getNodeByIdx(nodes, thisPlayer.nodeIdx);
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
            
            adminMessageText.text = board.adminMessage;
            lastWinnerText.text = board.lastWinner;
            score0Text.text = "SCORE: " + board.scores[0];
            score1Text.text = "SCORE: " + board.scores[1];
            score2Text.text = "SCORE: " + board.scores[2];
            score3Text.text = "SCORE: " + board.scores[3];
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
        
        function calculateMoveToNode(mousePos) {
            if (mousePos == undefined) {
                return undefined;
            }
            if (thisPlayer == undefined) {
                return undefined;
            }
            
            // find the best node to go to given the angle of the mouse click in
            // relation to the player's node
            var clickNode = undefined
            var clickNodeMinAngle = 999999999
            let nodes = lastBoardUpdate.nodes;
            let playerNode = getNodeByIdx(nodes, thisPlayer.nodeIdx);
            if (playerNode == undefined) {
                return undefined;
            }
            
            let playerNodePos = getNodePos(playerNode);
            
            // get the angle between the player's node pos and the mouse pos
            let nodeToMouseVec = vec2.create()
            vec2.set(nodeToMouseVec, (mousePos.x - playerNodePos[0]), (mousePos.y - playerNodePos[1]))

            let otherNodeVec = vec2.create()
            
            for (i in nodes) {
                let node = nodes[i];
                
                // disclude the player's node, only include nodes which are adjacent to player node
                if (node.id != thisPlayer.nodeIdx && playerNode.c.includes(node.id)) {
                    let pos = getNodePos(node);
                    
                    vec2.set(otherNodeVec, (pos[0] - playerNodePos[0]), (pos[1] - playerNodePos[1]))
                    
                    let angle = vec2.angle(nodeToMouseVec, otherNodeVec);
                                    
                    if (clickNode == undefined || angle < clickNodeMinAngle) {
                        clickNode = node;
                        clickNodeMinAngle = angle;
                    }
                }
            }
            
            return clickNode
        }
        
        function onPointerDown(event) {
            if (playerCanMove == false) {
                return;
            }
            
            let mousePos = event.data.getLocalPosition(gameContainer);
            
            var clickNode = calculateMoveToNode(mousePos);
            
            if (clickNode != undefined) {
                movePlayer(clickNode.id, function (info) {
                    if (info.tag == "BoardUpdate") {
                        updateBoard(info)
                    }
                })
            }
        }
        app.renderer.plugins.interaction.on('pointerdown', onPointerDown);
        
        function onPointerMove(event) {
            lastMousePos = event.data.getLocalPosition(gameContainer);
        }
        app.renderer.plugins.interaction.on('pointermove', onPointerMove);
        
        
        app.loader
        .add("player0", "player0.png")
        .add("player1", "player1.png")
        .add("player2", "player2.png")
        .add("player3", "player3.png")
        .add("star", "star.png")
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
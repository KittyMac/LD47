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
            
            // We need to reject out-of-order board updates.  The count value is 0-65535 and loops.
            if (lastBoardUpdate != undefined) {
                if (board.count > lastBoardUpdate.count ||
                    lastBoardUpdate.count >= 32767 && board.count < 32767) {
                
                } else {
                    print("skipping out of order board update")
                    return;
                }
            }
            
            lastBoardUpdate = board;
            
            // -1. we want to center the board around the player's nodeidx
            let nodes = board.nodes;
            let players = board.players;
            
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
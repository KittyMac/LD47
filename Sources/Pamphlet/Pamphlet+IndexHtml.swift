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
                
        
        function onPointerDown(event) {
            if (playerCanMove == false) {
                return;
            }
            if (thisPlayer == undefined) {
                return;
            }
            
            let mousePos = event.data.getLocalPosition(gameContainer)
            
            // find the node nearest the click
            var clickNode = undefined
            var clickNodeDistance = 999999999
            let nodes = lastBoardUpdate.nodes;
            let playerNode = getNodeByIdx(nodes, thisPlayer.nodeIdx);
            
            for (i in nodes) {
                let node = nodes[i];
                
                // disclude the player's node, only include nodes which are adjacent to player node
                if (node.id != thisPlayer.nodeIdx && playerNode.c.includes(node.id)) {
                    let pos = getNodePos(node);
                    let dx = (mousePos.x - pos[0])
                    let dy = (mousePos.y - pos[1])
                    let d = dx * dx + dy * dy;
                
                    if (clickNode == undefined || d < clickNodeDistance) {
                        clickNode = node;
                        clickNodeDistance = d;
                    }
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
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
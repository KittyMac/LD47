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
                let particle = particleContainer.children {
                    particle.life -= 16
                    if (particle.life) <= 0 {
                        particle.parent.removeChild(particle);
                    } else {
                        particle.velocity[0] *= particle.friction;
                        particle.velocity[1] *= particle.friction;
                        particle.x += particle.velocity[0];
                        particle.y += particle.velocity[1];
                    }
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
        
        function explode(x, y, num) {
            for (i = 0; i < num; i++) {
                let star = makeSprite(app, "star");
                star.life = 2000;
                star.velocity = [Math.random() * 10 - 5, Math.random() * 10 - 5]
                star.friction = 0.9;
                star.x = x + star.velocity[0] * 3.0;
                star.y = y + star.velocity[1] * 3.0;
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